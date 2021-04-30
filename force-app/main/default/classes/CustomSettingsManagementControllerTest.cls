/**
 * @description Test class for CustomSettingsManagementController
 *
 * @author  tomaschour
 * @date    2021-04-01
 */
@IsTest
private with sharing class CustomSettingsManagementControllerTest {

    /**
     * @description Tests that org defaults are returned when there are not user specific settings
     */
    @IsTest
    private static void testGetSettings_orgDefaults() {
        ABRA_Flexi_Data_Integration_Settings__c abraSettings = new ABRA_Flexi_Data_Integration_Settings__c(
                Company_Name__c = 'Test'
        );
        insert abraSettings;
        Test.startTest();
        ABRA_Flexi_Data_Integration_Settings__c result =
                (ABRA_Flexi_Data_Integration_Settings__c) CustomSettingsManagementController.getSettings('ABRA_Flexi_Data_Integration_Settings__c');
        Test.stopTest();
        System.assertEquals(ABRA_Flexi_Data_Integration_Settings__c.getOrgDefaults().Id, result.Id);
    }



    /**
     * @description Tests that exception is thrown for invalid argument
     */
    @IsTest
    private static void testSaveSettingsForCurrentUser_error() {
        Test.startTest();
        try {
            CustomSettingsManagementController.saveSettingsForCurrentUser(null);
        } catch (AuraHandledException ex) {
            // nothing to assert
        }
        Test.stopTest();
    }


    /**
     * @description Tests that user specific settings are returned over org defaults
     */
    @IsTest
    private static void testGetSettings_userSpecific() {
        ABRA_Flexi_Data_Integration_Settings__c abraSettingsOrgDef = new ABRA_Flexi_Data_Integration_Settings__c(
                Company_Name__c = 'Test'
        );
        ABRA_Flexi_Data_Integration_Settings__c abraSettingsOrgDefUserSpec = new ABRA_Flexi_Data_Integration_Settings__c(
                Company_Name__c = 'Test', SetupOwnerId = UserInfo.getUserId()
        );
        insert new List<ABRA_Flexi_Data_Integration_Settings__c>{
                abraSettingsOrgDef, abraSettingsOrgDefUserSpec
        };
        Test.startTest();
        ABRA_Flexi_Data_Integration_Settings__c result =
                (ABRA_Flexi_Data_Integration_Settings__c) CustomSettingsManagementController.getSettingsForSpecificUser('ABRA_Flexi_Data_Integration_Settings__c');
        Test.stopTest();
        System.assertEquals(abraSettingsOrgDefUserSpec.Id, result.Id);
    }


    /**
     * @description Tests that org defaults settings are returned when there are no user specific
     */
    @IsTest
    private static void testGetSettings_userSpecificOrgDef() {
        ABRA_Flexi_Data_Integration_Settings__c abraSettings = new ABRA_Flexi_Data_Integration_Settings__c(
                Company_Name__c = 'Test'
        );
        insert abraSettings;
        Test.startTest();
        ABRA_Flexi_Data_Integration_Settings__c result =
                (ABRA_Flexi_Data_Integration_Settings__c) CustomSettingsManagementController.getSettingsForSpecificUser('ABRA_Flexi_Data_Integration_Settings__c');
        Test.stopTest();
        System.assertEquals(ABRA_Flexi_Data_Integration_Settings__c.getOrgDefaults().Id, result.Id);
    }

    /**
     * @description Tests that exception is thrown for invalid argument
     */
    @IsTest
    private static void testGetSettings_error() {
        Test.startTest();
        try {
            CustomSettingsManagementController.getSettings(null);
        } catch (AuraHandledException ex) {
            // nothing to assert
        }
        Test.stopTest();
    }

    /**
     * @description Tests that user settings are updated
     */
    @IsTest
    private static void testSaveSettingsForCurrentUser_update() {
        ABRA_Flexi_Data_Integration_Settings__c abraSettingsOrgDefUserSpec = new ABRA_Flexi_Data_Integration_Settings__c(
                Company_Name__c = 'Test', SetupOwnerId = UserInfo.getUserId()
        );
        insert abraSettingsOrgDefUserSpec;
        abraSettingsOrgDefUserSpec.Company_Name__c = 'UpdatedName';
        Test.startTest();
        CustomSettingsManagementController.saveSettingsForCurrentUser(abraSettingsOrgDefUserSpec);
        Test.stopTest();
        List<ABRA_Flexi_Data_Integration_Settings__c> updatedSettings = [
                SELECT Id, Company_Name__c
                FROM ABRA_Flexi_Data_Integration_Settings__c
                WHERE SetupOwnerId = :UserInfo.getUserId()
        ];
        System.assertEquals(1, updatedSettings.size());
        System.assertEquals('UpdatedName', updatedSettings[0].Company_Name__c);
    }


    /**
     * @description Tests that org default settings are updated
     */
    @IsTest
    private static void testSaveOrgDefaultSettings_update() {
        ABRA_Flexi_Data_Integration_Settings__c orgDef = new ABRA_Flexi_Data_Integration_Settings__c(
                Company_Name__c = 'Test'
        );
        insert orgDef;
        orgDef.Company_Name__c = 'UpdatedName';
        Test.startTest();
        CustomSettingsManagementController.saveOrgDefaultSettings(orgDef);
        Test.stopTest();

        ABRA_Flexi_Data_Integration_Settings__c updatedSettings = ABRA_Flexi_Data_Integration_Settings__c.getOrgDefaults();
        System.assertEquals('UpdatedName', updatedSettings.Company_Name__c);
    }

    /**
     * @description Tests that user settings are created when non current user specific settings are provided
     */
    @IsTest
    private static void testSaveSettingsForCurrentUser_create() {
        ABRA_Flexi_Data_Integration_Settings__c orgDef = new ABRA_Flexi_Data_Integration_Settings__c(
                Company_Name__c = 'Test'
        );
        insert orgDef;
        orgDef.Company_Name__c = 'UpdatedName';
        Test.startTest();
        CustomSettingsManagementController.saveSettingsForCurrentUser(orgDef);
        Test.stopTest();
        List<ABRA_Flexi_Data_Integration_Settings__c> createdSettings = [
                SELECT Id, Company_Name__c
                FROM ABRA_Flexi_Data_Integration_Settings__c
                WHERE SetupOwnerId = :UserInfo.getUserId()
        ];
        System.assertEquals(1, createdSettings.size());
        System.assertEquals('UpdatedName', createdSettings[0].Company_Name__c);
    }
}