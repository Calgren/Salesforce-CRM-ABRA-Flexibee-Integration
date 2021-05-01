/**
 * @description Scheduler for AbraSobjectExportBatch
 * define objects for which you want to run export batch in batchRunsConfigurations List
 *
 * @author tomaschour
 * @date 2021-04-25
 */
public with sharing class AbraDataExportScheduler implements Schedulable {

    // list with batch runs configurations
    @TestVisible
    private final List<AbraSobjectExportBatch.ExportBatchRunConfiguration> batchRunsConfigurations = new List<AbraSobjectExportBatch.ExportBatchRunConfiguration>{
            new AbraSobjectExportBatch.ExportBatchRunConfiguration('Order', 'objednavka-prijata', 'ABRA_Flexi_Data_Exported__c'),
            new AbraSobjectExportBatch.ExportBatchRunConfiguration('Invoice__c', 'faktura-vydana', 'ABRA_Flexi_Data_Exported__c')
    };
    private static final String JOB_NAME = 'SfscToAbraExport';

    /**
     * @description executes sync batches for each object defined in batchRunsConfigurations and schedules
     * next run
     *
     * @param ctx SchedulableContext
     * @author tomaschour
     * @date 2021-04-25
     */
    public void execute(SchedulableContext ctx) {
        // run batch export for every supported object
        executeBatchForEveryObject();
        // Delete old scheduled jobs
        clearOldScheduledApexJobs();
        // schedule next run
        scheduleNext();
        // TODO commit logs
    }

    /**
     * @description for each SObject defined in dataObtainedFlagsBySObjectsToSync Map executes synchronization batch.
     *
     * @author tomaschour
     * @date 2021-04-25
     */
    @SuppressWarnings ('PMD.OperationWithLimitsInLoop')
    private void executeBatchForEveryObject() {
        // execute batch in cycle because executing for multiple sobjects for multiple SObjects
        for (AbraSobjectExportBatch.ExportBatchRunConfiguration batchRunCongfig : batchRunsConfigurations) {
            try {
                AbraSobjectExportBatch syncBatch = new AbraSobjectExportBatch(null, batchRunCongfig);
                Database.executeBatch(syncBatch, 1);
            } catch (Exception e) {
                System.debug('Error during AbraSobjectExportBatch schedule for: ' + batchRunCongfig.abraObjectName);
                //TODO Logging
            }
        }
    }

    /**
     * @description Schedules next run of SfccSObjectSyncScheduler
     *
     * @author tomaschour
     * @date 2021-04-25
     */
    private void scheduleNext() {
        Integer scheduleInterval =
                ((Decimal) AbraFlexiDataIntegrationSettings.getAttributeValue(
                        ABRA_Flexi_Data_Integration_Settings__c.Integration_Interval_In_Minutes__c
                )).intValue();
        Datetime nextTime = System.now();
        nextTime = nextTime.addMinutes(scheduleInterval);
        String strJobName = JOB_NAME + System.now().getTime();
        String strSchedule = nextTime.format('0 m H d MM ? yyyy');
        System.schedule(strJobName, strSchedule, new AbraDataExportScheduler());
    }

    /**
     * @description Deletes old jobs from the schedule table.
     *
     * @author tomaschour
     * @date 2021-04-25
     */
    public void clearOldScheduledApexJobs() {
        String pattern = JOB_NAME + '%';
        for (CronTrigger cron : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :pattern AND (State = 'DELETED' OR State = 'COMPLETE')]) {
            System.abortJob(cron.Id);
        }
    }
}