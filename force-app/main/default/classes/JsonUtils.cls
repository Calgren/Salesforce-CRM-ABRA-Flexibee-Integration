/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-28
 */
public with sharing class JsonUtils {

    /**
     * @description retrieves value in correct format from JSON by attribute name
     * @param keyString name of CC object attribute
     * @param jsonObject json response from CC
     * @return value from json for specified attribute
     */
    public static Object getValueByKey(String keyString, Map<String, Object> jsonObject) {
        List<String> keys = keyString.split('\\.');
        Object value;
        String index;
        try {
            if (keys.size() < 1) {
                return value;
            }
            for (Integer i = 0; i < keys.size(); i++) {
                String key = keys.get(i);
                if (key.contains('[')) {
                    value = jsonObject.get(key.substring(0, key.indexOf('[')));
                    if (value instanceof List<Object>) {
                        index = key.substring(key.indexOf('[') + 1, key.indexOf(']'));
                        if (index.equalsIgnoreCase('n')) {
                            String compositeChildKey = getCompositeChildKey(keys, i + 1);
                            i = i + compositeChildKey.split('\\.').size();
                            for (Object element : ((List<Object>) value)) {
                                value = getValueByKey(compositeChildKey, (Map<String, Object>) element);
                            }
                        } else {
                            List<Object> objects = (List<Object>) value;
                            value = (objects.size() - 1 >= Integer.valueOf(index) ? objects.get(Integer.valueOf(index)) : null);
                        }
                    } else {
                    }
                } else {
                    value = jsonObject.get(key);
                }
                if (i == keys.size() - 1 && (value instanceof String
                        || value instanceof Boolean
                        || value instanceof Decimal
                        || value instanceof Integer)) {
                    break;
                } else if (value instanceof Map<String, Object>) {
                    jsonObject = (Map<String, Object>) value;
                } else {
                    value = null;
                    break;
                }
            }
        } catch (Exception e) {
            new ApexLog().createLog(
                    new ApexLog.Error(
                            'JsonUtils',
                            'getValueByKey',
                            null,
                            e
                    )
            );
        }
        return value;
    }

    private static String getCompositeChildKey(List<String> keys, Integer startingIndex) {
        String compositeChildKey;
        for (Integer i = startingIndex; i < keys.size(); i++) {
            if (String.isEmpty(compositeChildKey)) {
                compositeChildKey = keys.get(i);
            } else {
                compositeChildKey = compositeChildKey + '.' + keys.get(i);
            }
        }
        return compositeChildKey;
    }

    /**
     * @description This method create string object map using patched data so later it can be serialized to JSON.
     * @param sobjectToConvert sobject to convert to json map
     * @param objectName api name of SObject
     * @return map with CC attribute name as key and value from SF
     */
    public static Map<String, Object> initializeJsonObject(SObject sobjectToConvert, Map<String, SObject> fieldMappings) {
        Map<String, Object> patchDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sobjectToConvert));
        Map<String, Object> jsonObject = new Map<String, Object>();
        Set<String> patchDataMapKeySet = patchDataMap.keySet();
        String objectMappingvalue;
        for (String key : fieldMappings.keySet()) {
            objectMappingvalue = ((String) fieldMappings.get(key).get('SFSC_Field_Name__c')).toLowerCase();
            if (patchDataMapKeySet.contains(objectMappingvalue) && !key.contains('[')) {
                List<String> keyElements = key.split('\\.');
                if (keyElements.size() > 1) {
                    Map<String, Object> tempJsonObjMap = null;
                    for (Integer i = keyElements.size() - 1; i >= 0; i--) {
                        String keyComponent = keyElements.get(i);
                        if (keyComponent.contains('[')) {
                            //To do for later
                        } else {
                            //If top element then add in jsonOBject
                            if (i == 0) {
                                jsonObject.put(keyComponent, tempJsonObjMap);
                            } else if (i == keyElements.size() - 1) {
                                tempJsonObjMap = new Map<String, Object>{
                                        keyComponent => patchDataMap.get(objectMappingvalue)
                                };
                            } else {
                                tempJsonObjMap = new Map<String, Object>{
                                        keyComponent => tempJsonObjMap
                                };
                            }
                        }
                    }
                } else {
                    jsonObject.put(key, patchDataMap.get(objectMappingvalue));
                }
            }
        }
        return jsonObject;
    }
}