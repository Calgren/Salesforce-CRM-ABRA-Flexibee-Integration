/**
 * @description contains methods to initialize SObject from response from external system
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-22
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public inherited sharing class IntegrationSObjectUtils {

    /**
     * @description This method is used to get object attribute mapping values from specified object.
     *
     * @param abraObjectName Abra Object API name
     * @return Map of Field mapping metadata by Commerce Cloud attribute name
     */
    public static Map<String, ABRA_Flexi_Data_Mapping__mdt> getAllMappingsByAbraAttributeName(String abraObjectName) {
        Map<String, ABRA_Flexi_Data_Mapping__mdt> mappingsByAbraAttributeName = new Map<String, ABRA_Flexi_Data_Mapping__mdt>();
        for (ABRA_Flexi_Data_Mapping__mdt mapping : getFieldMappingsForAbraObject(abraObjectName)) {
            mappingsByAbraAttributeName.put((String) mapping.ABRA_Flexi_Field_Name__c, mapping);
        }
        return mappingsByAbraAttributeName;
    }

    /**
     * @description This method is used to get object field mapping values applicable for sync from specified object.
     *
     * @param abraObjectName Abra Object API name
     * @param isSync select fields with Enable_Sync__c true/false
     * @return Map of Field mapping metadata by Commerce Cloud attribute name
     */
    public static Map<String, ABRA_Flexi_Data_Mapping__mdt> getImportMappingsByAbraAttributeName(String abraObjectName, Boolean isSync) {
        Map<String, ABRA_Flexi_Data_Mapping__mdt> mappingsByAbraAttributeName = new Map<String, ABRA_Flexi_Data_Mapping__mdt>();
        for (ABRA_Flexi_Data_Mapping__mdt mapping : getFieldMappingsForAbraObject(abraObjectName)) {
            if (mapping.ABRA_Flexi_To_SFSC_Sync__c == isSync) {
                mappingsByAbraAttributeName.put((String) mapping.ABRA_Flexi_Field_Name__c, mapping);
            }
        }
        return mappingsByAbraAttributeName;
    }

    /**
     * @description This method is used to get object field mapping values applicable for patch from specified object.
     *
     * @param abraObjectName Abra Object API name
     * @param isPatch select fields with Enable_Patch__c true/false
     * @return Map of Field mapping metadata by Commerce Cloud attribute name
     */
    public static Map<String, ABRA_Flexi_Data_Mapping__mdt> getExportMappingsByAbraAttributeName(String abraObjectName, Boolean isPatch) {
        Map<String, ABRA_Flexi_Data_Mapping__mdt> mappingsByAbraAttributeName = new Map<String, ABRA_Flexi_Data_Mapping__mdt>();
        for (ABRA_Flexi_Data_Mapping__mdt mapping : getFieldMappingsForAbraObject(abraObjectName)) {
            if (mapping.SFSC_To_ABRA_Flexi_Sync__c == isPatch) {
                mappingsByAbraAttributeName.put((String) mapping.ABRA_Flexi_Field_Name__c, mapping);
            }
        }
        return mappingsByAbraAttributeName;
    }

    /**
     * @description selects Commerce Cloud field mappings for specified SObjects
     *
     * @param abraObjectName name of abra entity
     * @return List of Commerce Cloud Field Mappings for specified SObject
     *
     * @author Tomas Chour - AspectWorks
     * @date 2021-01-22
     */
    private static List<ABRA_Flexi_Data_Mapping__mdt> getFieldMappingsForAbraObject(String abraObjectName) {
        Map<String, List<ABRA_Flexi_Data_Mapping__mdt>> fieldMappingsByObjectName = getFieldMappingsByAbraObjectName();
        if (!fieldMappingsByObjectName.containsKey(abraObjectName)) {
            throw new Exceptions.BadDataException('ABRA mappings for ' + abraObjectName + ' do not exist.');
        } else {
            return fieldMappingsByObjectName.get(abraObjectName);
        }
    }

    /**
     * @description selects Commerce Cloud field mappings grouped by SObject api names
     *
     * @return Map of Commerce Cloud Field Mappings grouped by SObject API name
     *
     * @author Tomas Chour - AspectWorks
     * @date 2021-01-21
     */
    private static Map<String, List<ABRA_Flexi_Data_Mapping__mdt>> getFieldMappingsByAbraObjectName() {
        Map<String, List<ABRA_Flexi_Data_Mapping__mdt>> mappingsBySObject = new Map<String, List<ABRA_Flexi_Data_Mapping__mdt>>();
        for (ABRA_Flexi_Data_Mapping__mdt fieldMapping : (List<ABRA_Flexi_Data_Mapping__mdt>) ABRA_Flexi_Data_Mapping__mdt.getAll().values()) {
            if (!mappingsBySObject.containsKey(fieldMapping.ABRA_Flexi_Entity_Name__c)) {
                mappingsBySObject.put(fieldMapping.ABRA_Flexi_Entity_Name__c, new List<ABRA_Flexi_Data_Mapping__mdt>());
            }
            mappingsBySObject.get(fieldMapping.ABRA_Flexi_Entity_Name__c).add(fieldMapping);
        }
        return mappingsBySObject;
    }
}