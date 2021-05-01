/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-28
 */
public with sharing class AbraInvoiceDataSyncService implements AbraSynchronizationInterface{

    public void exportRecords(List<SObject> records, Map<String, Object> params) {
        if ((Boolean) AbraFlexiDataIntegrationSettings.getAttributeValue(ABRA_Flexi_Data_Integration_Settings__c.Invoice_Data_Integration_Is_Active__c)) {
            AbraUtils.exportSObjects(records, String.valueOf(params.get(AbraUtils.ABRA_OBJECT_NAME_PARAM )));
        }
    }

}