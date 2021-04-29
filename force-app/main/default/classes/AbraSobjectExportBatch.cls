/**
 * 
 *
 * @author  tomaschour
 * @date    2021-04-28
 */
public with sharing class AbraSobjectExportBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    //private final static awsp.Logger LOG = awsp.LoggerFactory.getLogger(SfccSObjectSyncBatch.class);
    private String objectApiName;
    private String abraObjectName;
    private Set<Id> objectIdsToSync;
    private String recordExportedFlag;
    private String abraIdField;
    private String additionalCondition;
    private String normalizedSObjectApiName;

    /**
     * @description batch constructor
     * @param objectIdsToSync Set of Ids of Objects to Sync
     * @param configuration batch configuration DTO
     */
    public AbraSobjectExportBatch(Set<Id> objectIdsToSync, ExportBatchRunConfiguration configuration) {
        this.objectIdsToSync = objectIdsToSync;
        this.recordExportedFlag = configuration.recordExportedFlag;
        this.abraIdField = configuration.abraIdField;
        this.objectApiName = configuration.sObjectApiName;
        this.abraObjectName = configuration.abraObjectName;
        this.additionalCondition = configuration.additionalCondition;
        this.normalizedSObjectApiName = configuration.sObjectApiName.replace('__c', '').replace('_', '');
    }

    /**
     * @description batch start method - creates dynamic query with data provided in constructor and returns query locator
     * @param bc batchable context
     *
     * @return query locator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            String soqlQuery;
            if (this.objectIdsToSync == null && recordExportedFlag != null) {
                soqlQuery = 'SELECT Id FROM ' + objectApiName + ' WHERE '
                        + recordExportedFlag + ' = FALSE';
            } else {
                soqlQuery = 'SELECT Id FROM ' + objectApiName + ' WHERE Id IN :objectIdsToSync';
            }
            if (additionalCondition != null) {
                soqlQuery += ' AND ' + additionalCondition;
            }
            return Database.getQueryLocator(soqlQuery);
        } catch (Exception e) {
            //LOG.error('Error during object synchronization from SFCC.', e);
            return null;
        } finally {
            //awsp.LoggerFactory.saveLogs();
        }
    }

    /**
     * @description batch execute method - updates Sobject with data pulled from SFCC
     * @param bc batchable context
     * @param scope list of sobject to update with data from SFCC
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        for (SObject theSObject : scope) {
            try {
                AbraSynchronizationInterface handler = (AbraSynchronizationInterface) Type.forName('Abra' + this.normalizedSObjectApiName + 'DataSyncService').newInstance();
                handler.exportRecords(scope, new Map<String, Object>{AbraUtils.ABRA_OBJECT_NAME_PARAM => this.abraObjectName});
            } catch (Exception e) {
                System.debug('Error ' + e.getMessage());
                //LOG.error('Error during object synchronization from SFCC. ' + theSObject?.Id, e);
            } finally {
                //awsp.LoggerFactory.saveLogs();
            }
        }
    }

    /**
     * @description batch finish method
     * @param bc batchable context
     */
    public void finish(Database.BatchableContext bc) {

    }


    /**
     * @description class used as dto for export batch configuration
     */
    public class ExportBatchRunConfiguration {
        public String sObjectApiName;
        public String abraObjectName;
        public String recordExportedFlag;
        public String abraIdField;
        public String additionalCondition;

        /**
         * @description constructor
         *
         * @param sObjectApiName SObject api name to synchronize
         * @param abraObjectName API name of ABRA entity
         * @param recordExportedFlag API name of field that indicates whether record relevant data has been exported to ABRA
         * @param abraIdField API name of external id field that is used as ID in ABRA
         */
        public ExportBatchRunConfiguration(String sObjectApiName, String abraObjectName, String recordExportedFlag, String abraIdField) {
            this.sObjectApiName = sObjectApiName;
            this.abraObjectName = abraObjectName;
            this.recordExportedFlag = recordExportedFlag;
            this.abraIdField = abraIdField;
        }

        /**
         * @description constructor
         *
         * @param sObjectApiName SObject api name to synchronize
         * @param abraObjectName API name of ABRA entity
         * @param recordExportedFlag API name of field that indicates whether record relevant data has been exported to ABRA
         * @param abraIdField API name of external id field that is used as ID in ABRA
         * @param additionalCondition additional condition to filter records to export by
         */
        public ExportBatchRunConfiguration(String sObjectApiName, String abraObjectName, String recordExportedFlag,
                String abraIdField, String additionalCondition) {
            this.sObjectApiName = sObjectApiName;
            this.abraObjectName = abraObjectName;
            this.recordExportedFlag = recordExportedFlag;
            this.abraIdField = abraIdField;
            this.additionalCondition = additionalCondition;
        }
    }
}