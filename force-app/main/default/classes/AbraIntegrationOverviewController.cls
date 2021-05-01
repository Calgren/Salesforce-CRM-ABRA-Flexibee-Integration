/**
 * 
 *
 * @author  tomaschour
 * @date    2021-05-25
 */
public with sharing class AbraIntegrationOverviewController {

    @AuraEnabled
    public static IntegrationOverviewDto getBatchRunsInfo(){
        try {
            IntegrationOverviewDto dto = new IntegrationOverviewDto();
            dto.isCurrentlyRunning = false;
            String pattern = AbraDataExportScheduler.JOB_NAME + '%';
            List<CronTrigger> cronTriggers = [SELECT Id, PreviousFireTime, NextFireTime, State FROM CronTrigger WHERE CronJobDetail.Name LIKE :pattern];
            for(CronTrigger theCronTrigger : cronTriggers) {
                if (theCronTrigger.NextFireTime != null) {
                    dto.nextRunDatetime = theCronTrigger.NextFireTime;
                }
                else if (theCronTrigger.PreviousFireTime != null) {
                    dto.lastRunDatetime = theCronTrigger.PreviousFireTime;
                }
                if (theCronTrigger.State == 'ACQUIRED' || theCronTrigger.State == 'EXECUTING') {
                    dto.isCurrentlyRunning = true;
                }
            }
            return dto;
        } catch(Exception e) {
            new ApexLog().createLog(
                    new ApexLog.Error(
                            'AbraIntegrationOverviewController',
                            'getBatchRunsInfo',
                            null,
                            e
                    )
            );
            throw new AuraHandledException('Exception when getting integration info ' + e.getMessage());
        } finally {
            ApexLog.commitLogs();
        }
    }

    public class IntegrationOverviewDto{
        @AuraEnabled public Datetime lastRunDatetime;
        @AuraEnabled public Datetime nextRunDatetime;
        @AuraEnabled public Boolean isCurrentlyRunning;
    }
}