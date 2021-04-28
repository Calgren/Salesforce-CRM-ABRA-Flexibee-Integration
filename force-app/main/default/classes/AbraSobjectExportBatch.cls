/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-28
 */
public with sharing class AbraSobjectExportBatch implements Database.Batchable<SObject>, Database.AllowsCallouts{

    //private final static awsp.Logger LOG = awsp.LoggerFactory.getLogger(SfccSObjectSyncBatch.class);
    private String objectApiName;
    private String abraObjectName;
    private Set<Id> objectIdsToSync;
    private String recordUpdatedFlag;
    private String sfccIdentificationField;
    private String additionalCondition;
    private String normalizedSObjectApiName;

    /**
     * @description batch constructor
     * @param objectApiName api name of SObjects to export to ABRA Flexi
     * @param objectIdsToSync Set of Ids of Objects to Sync
     * @param recordUpdatedFlag API name of fields on SObject that indicates that record data has been updated with data from SFCC
     * @param sfccIdentificationField API name of field on SObject that is used for selection in SFCC
     */
    public AbraSobjectExportBatch(String objectApiName, String abraObjectName, Set<Id> objectIdsToSync, String recordUpdatedFlag,
            String sfccIdentificationField, String additionalCondition) {
        this.objectIdsToSync = objectIdsToSync;
        this.recordUpdatedFlag = recordUpdatedFlag;
        this.sfccIdentificationField = sfccIdentificationField;
        this.objectApiName = objectApiName;
        this.abraObjectName = abraObjectName;
        this.additionalCondition = additionalCondition;
        this.normalizedSObjectApiName = objectApiName.replace('__c', '').replace('_', '');
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
            if (this.objectIdsToSync == null && recordUpdatedFlag != null) {
                soqlQuery = 'SELECT Id FROM ' + objectApiName + ' WHERE '
                        + recordUpdatedFlag + ' = FALSE AND ' + sfccIdentificationField + ' != NULL';
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
}