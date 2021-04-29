/**
 * @description retrieves values from ABRA_Flexi_Data_Integration_Settings__c
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-25
 */
public with sharing class AbraFlexiDataIntegrationSettings {

    /**
     * @description gets org defaults of SFCC_Configuration__c only once for one apex transaction
     */
    private static ABRA_Flexi_Data_Integration_Settings__c orgDefaults {
        get {
            if (orgDefaults == null) {
                orgDefaults = ABRA_Flexi_Data_Integration_Settings__c.getOrgDefaults();
            }
            return orgDefaults;
        }
        set;
    }

    /**
     * @description retrieves value from ABRA_Flexi_Data_Integration_Settings__c org defaults
     * checks for nulls if field is required
     *
     * @param field field to be value retrieved from
     *
     * @return value from field
     */
    public static Object getAttributeValue(SObjectField field) {
        Object value = orgDefaults.get(field);
        if (!field.getDescribe().isNillable() && value == null) {
            throw new Exceptions.BadConfigurationException('ABRA_Flexi_Data_Integration_Settings__c missing value for : '
                    + field.getDescribe().name +' field');
        }
        return value;
    }
}