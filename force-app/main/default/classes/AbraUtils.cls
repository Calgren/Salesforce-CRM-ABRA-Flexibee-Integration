/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-28
 */
public with sharing class AbraUtils {
    public final static String EXPORT_ROOT_ATTRIBUTE = 'winstrom';
    public final static String ABRA_OBJECT_NAME_PARAM = 'abraObjectName';

    private static String getUpsertJsonForEntities(List<SObject> sObjects, String abraObjectName, Map<String, SObject> fieldMappings) {
        Map<String, Map<String, List<Map<String, Object>>>> mapJsonStructure = new Map<String, Map<String, List<Map<String, Object>>>>();
        mapJsonStructure.put(EXPORT_ROOT_ATTRIBUTE, new Map<String, List<Map<String, Object>>>());
        List<Map<String, Object>> listOfRecordsInMapFormat = new List<Map<String, Object>>();
        for (SObject o : sObjects) {
            listOfRecordsInMapFormat.add(JsonUtils.initializeJsonObject(o, fieldMappings));
        }
        mapJsonStructure.get(EXPORT_ROOT_ATTRIBUTE).put(abraObjectName, listOfRecordsInMapFormat);
        return JSON.serialize(mapJsonStructure);
    }


    public static void exportSObjects(List<SObject> sObjects, String abraEntity) {
        Map<String, SObject> fieldMappings = IntegrationSObjectUtils.getExportMappingsByAbraAttributeName(abraEntity, true);
        Set<Id> sobjectIds = new Set<Id>();
        for (SObject o : sObjects) {
            sobjectIds.add(o.Id);
        }
        String query = buildQueryFromMapping(sobjectIds, fieldMappings);
        List<SObject> sObjectsWithAllValuesFromMappings = Database.query(query);
        getUpsertJsonForEntities(sObjectsWithAllValuesFromMappings, abraEntity, fieldMappings);
    }

    private static String buildQueryFromMapping(Set<Id> sObjectIds, Map<String, SObject> fieldMappings) {
        String query = 'SELECT {0} FROM {1} WHERE ID IN {2}';
        String sobjectIdsForQuery = '(' + String.join(new List<Id>(sObjectIds), ',') + ')';
        String sObjectName = String.valueOf(fieldMappings.values()[0].get('SFSC_SObject_Name__c'));
        Set<String> fieldApiNames = new Set<String>();
        for(SObject mapping : fieldMappings.values()) {
            fieldApiNames.add(String.valueOf(mapping.get('SFSC_Field_Name__c')));
        }
        return String.format(query, new List<String>{String.join(new List<String>(fieldApiNames), ','),
                sObjectName,
                sobjectIdsForQuery});
    }
}