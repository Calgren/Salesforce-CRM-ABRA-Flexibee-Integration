/**
 * @description contains methods to initialize SObject from response from external system
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-22
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public inherited sharing class IntegrationSObjectUtils {
/*
    private static final Set<String> EXTERNAL_PHONE_ATTRIBUTES = new Set<String>{
            'billing_phone', 'phone_home', 'phone'
    };

    private static final Set<String> ATTRIBUTES_TO_REMOVE_HTML_TAGS = new Set<String>{
            'long_description'
    };

    private static final Map<String, Integer> ATTRIBUTES_TO_SHORTEN_CONTENT = new Map<String, Integer>{
            'long_description' => 3000,
            'short_description' => 1000
    }; */

    /**
    * @description This method used for initializing the object.
    * @param jsonMap Map<String, SObject>
    * @param objectName String
    * @param fieldMappings mappings with external system attribute name as a key
    * @return SObject.
    */
    public static SObject initializeObject(Map<String, Object> jsonMap, String objectName, Map<String, SObject> fieldMappings) {
        return createObject(jsonMap, objectName, fieldMappings);
    }

    /**
     * @description This method used for initializing the object.
     * @param objectToInitialize - Object to initialize.
     * @param objectName String
     * @param fieldMappings mappings with external system attribute name as a key
     * @return SObject.
     */
    public static SObject initializeObject(Object objectToInitialize, String objectName, Map<String, SObject> fieldMappings) {
        Map<String, Object> serializedObjectToMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objectToInitialize));
        return createObject(serializedObjectToMap, objectName, fieldMappings);
    }

    /**
     * @description This method used for returned sobject instance dynamically.
     *
     * @param objectName String
     * @return SObject.
     */
    public static SObject getNewSObject(String objectName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = gd.get(objectName);
        SObject obj = objectType.newSObject();
        return obj;
    }

    /**
     * @description This method used for populating fields the object.
     *
     * @param jsonMap Map<String, SObject>
     * @param objectName String
     * @param fieldMappings mappings with external system attribute name as a key
     * @return SObject.
     */
    public static SObject createObject(Map<String, Object> jsonMap, String objectName, Map<String, SObject> fieldMappings) {
        SObject obj = getNewSObject(objectName);
        populateSObjectFields(jsonMap, obj, objectName, fieldMappings);
        return obj;
    }

    /**
     * @description populates SObject fields with external system values from jsonMap based on provided mapping
     *
     * @param jsonMap map with values from external system
     * @param obj SObject to fill values into
     * @param objectName API name of SObject
     * @param fieldMappings field mappings between SFSC and external system for SObject - key is external system attribute name
     *
     * @author Tomas Chour - AspectWorks
     * @date 2021-01-25
     */
    public static void populateSObjectFields(Map<String, Object> jsonMap, SObject obj, String objectName, Map<String, SObject> fieldMappings) {
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> mFields = objectType.getDescribe().fields.getMap();
        for (String key : fieldMappings.keySet()) {
            Object value = JsonUtils.getValueByKey(key, jsonMap);
            if (value == null) {
                continue;
            }
            Schema.SObjectField field = (Schema.SObjectField) mFields.get((String) fieldMappings.get(key).get('Field_API_Name__c'));
            IntegrationSObjectUtils.populateSObjectField(key, value, field, obj, fieldMappings);
        }
    }

    /**
     * @description populates SObject field with external system values from jsonMap based on provided mapping
     * formats value based on field display type
     *
     * @param key field name in external system
     * @param value value from external system
     * @param field SF field to be populated
     * @param obj SObject to fill values into
     * @param fieldMappings field mappings between SFSC and external system for SObject - key is external system attribute name
     *
     * @author  tomaschour
     * @date    2021-04-22
     */
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts,PMD.CognitiveComplexity')
    @TestVisible
    private static void populateSObjectField(String key, Object value, Schema.SObjectField field,
            SObject obj, Map<String, SObject> fieldMappings) {
        if (field == null) {
            throw new Exceptions.BadConfigurationException('Mapping for: ' + key
                    + ' is invalid, check if SFSC_Field_Name__c is correctly set.');
        }
        if (value != null) { // do not set null values
            Schema.DisplayType fieldType = field.getDescribe().getType();
            // split types by the need of value casting to string
            if (fieldType == Schema.DisplayType.INTEGER) {
                obj.put((String) fieldMappings.get(key).get('SFSC_Field_Name__c'), Integer.valueOf(value));
            } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                obj.put((String) fieldMappings.get(key).get('SFSC_Field_Name__c'), Boolean.valueOf(value));
            } else {
                final String valueStr = String.valueOf(value);
                if (String.isNotBlank(valueStr)) { // do not set blank values
                    if (fieldType == Schema.DisplayType.CURRENCY ||
                            fieldType == Schema.DisplayType.DOUBLE) {
                        obj.put((String) fieldMappings.get(key).get('SFSC_Field_Name__c'), Decimal.valueOf(valueStr));
                    } else if (fieldType == Schema.DisplayType.PERCENT) {
                        obj.put((String) fieldMappings.get(key).get('SFSC_Field_Name__c'), Decimal.valueOf(valueStr) * 100);
                    } else if (fieldType == Schema.DisplayType.DATETIME) {
                        obj.put((String) fieldMappings.get(key).get('SFSC_Field_Name__c'), formatStringDateToDateTime(valueStr));
                    } else if (fieldType == Schema.DisplayType.DATE) {
                        if (valueStr.contains('-')) {
                            obj.put((String) fieldMappings.get(key).get('SFSC_Field_Name__c'), Date.valueOf(valueStr));
                        } else {
                            obj.put((String) fieldMappings.get(key).get('SFSC_Field_Name__c'), Date.parse(valueStr));
                        }
                    } else {
                        obj.put((String) fieldMappings.get(key).get('SFSC_Field_Name__c'), formatTextForSpecialFields(key, valueStr));
                    }
                }
            }
        }
    }

    /**
    * @description This method parse date string to DateTime
    * @param dateString String
    * @return DateTime.
    */
    public static Datetime formatStringDateToDateTime(String dateString) {
        return (Datetime) JSON.deserialize('"' + dateString + '"', Datetime.class);
    }

    /**
     * @description This methods is used to format values from fields that have to pass validation rule,
     * or have to be in special format and value from external system can be in different format
     * @param key name of attribute in external system
     * @param value attribute value returned from external system
     * @return formatted value to match SFSC criteria
     */
    private static String formatTextForSpecialFields(String key, Object value) {
        // use for special field formatting to pass validation rules
        String formattedValue = String.valueOf(value);
        /*
        // if value from sfcc is phone - remove all spaces, (,),-  to meet validation rules in sfsc
        if (EXTERNAL_PHONE_ATTRIBUTES.contains(key)) {
            formattedValue = formattedValue.deleteWhitespace().replaceAll('[-()s]', '');
        }
        if (ATTRIBUTES_TO_REMOVE_HTML_TAGS.contains(key)) {
            formattedValue = formattedValue.stripHtmlTags();
        }
        if (ATTRIBUTES_TO_SHORTEN_CONTENT.containsKey(key)) {
            formattedValue = formattedValue.left(ATTRIBUTES_TO_SHORTEN_CONTENT.get(key));
        }
        */
        return formattedValue;
    }




    /**
     * @description This method is used to get object attribute mapping values from specified object.
     *
     * @param objectName SObject API name
     * @return Map of Field mapping metadata by Commerce Cloud attribute name
     */
    public static Map<String, ABRA_Flexi_Data_Mapping__mdt> getAllMappingsByAbraAttributeName(String objectName) {
        Map<String, ABRA_Flexi_Data_Mapping__mdt> mappingsByAbraAttributeName = new Map<String, ABRA_Flexi_Data_Mapping__mdt>();
        for (ABRA_Flexi_Data_Mapping__mdt mapping : getFieldMappingsForAbraObject(objectName)) {
            mappingsByAbraAttributeName.put((String) mapping.ABRA_Flexi_Field_Name__c, mapping);
        }
        return mappingsByAbraAttributeName;
    }

    /**
     * @description This method is used to get object field mapping values applicable for sync from specified object.
     *
     * @param objectName SObject API name
     * @param isSync select fields with Enable_Sync__c true/false
     * @return Map of Field mapping metadata by Commerce Cloud attribute name
     */
    public static Map<String, ABRA_Flexi_Data_Mapping__mdt> getImportMappingsByAbraAttributeName(String objectName, Boolean isSync) {
        Map<String, ABRA_Flexi_Data_Mapping__mdt> mappingsByAbraAttributeName = new Map<String, ABRA_Flexi_Data_Mapping__mdt>();
        for (ABRA_Flexi_Data_Mapping__mdt mapping : getFieldMappingsForAbraObject(objectName)) {
            if (mapping.ABRA_Flexi_To_SFSC_Sync__c == isSync) {
                mappingsByAbraAttributeName.put((String) mapping.ABRA_Flexi_Field_Name__c, mapping);
            }
        }
        return mappingsByAbraAttributeName;
    }

    /**
     * @description This method is used to get object field mapping values applicable for patch from specified object.
     *
     * @param objectName SObject API name
     * @param isPatch select fields with Enable_Patch__c true/false
     * @return Map of Field mapping metadata by Commerce Cloud attribute name
     */
    public static Map<String, ABRA_Flexi_Data_Mapping__mdt> getExportMappingsByAbraAttributeName(String objectName, Boolean isPatch) {
        Map<String, ABRA_Flexi_Data_Mapping__mdt> mappingsByAbraAttributeName = new Map<String, ABRA_Flexi_Data_Mapping__mdt>();
        for (ABRA_Flexi_Data_Mapping__mdt mapping : getFieldMappingsForAbraObject(objectName)) {
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
    public static List<ABRA_Flexi_Data_Mapping__mdt> getFieldMappingsForAbraObject(String abraObjectName) {
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
    public static Map<String, List<ABRA_Flexi_Data_Mapping__mdt>> getFieldMappingsByAbraObjectName() {
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