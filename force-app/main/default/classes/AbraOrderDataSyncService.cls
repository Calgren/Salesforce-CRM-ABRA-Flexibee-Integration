/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-28
 */
public with sharing class AbraOrderDataSyncService implements AbraSynchronizationInterface{

    public void exportRecords(List<SObject> records, Map<String, Object> params) {
        AbraUtils.exportSObjects(records, String.valueOf(params.get(AbraUtils.ABRA_OBJECT_NAME_PARAM )));
    }

}