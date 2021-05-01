/**
 * @description controller for CustomSettingsManagement - selects and saves settings
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-01
 */
public with sharing class CustomSettingsManagementController {

    /**
     * @description retrieves specified custom settings org defaults
     *
     * @param customSettingsApiName API name of custom settings
     *
     * @return custom settings with all its fields org defaults
     */
    @AuraEnabled
    public static SObject getSettings(String customSettingsApiName) {
        try {
            if (customSettingsApiName == null) {
                throw new Exceptions.BadDataException('customSettingsApiName cannot be null');
            }
            final String soqlTemplate = 'SELECT {0} FROM {1} WHERE SetupOwnerId = {2}';
            Set<String> fieldNames = Schema.describeSObjects(new String[]{
                    customSettingsApiName
            })[0].fields.getMap().keySet();
            List<String> iterableFields = new List<String>(fieldNames);
            List<SObject> customSettingsList = Database.query(
                    String.format(soqlTemplate,
                            new String[]{
                                    String.join(iterableFields, ','), customSettingsApiName, '\'' + UserInfo.getOrganizationId() + '\''
                            })
            );
            if (!customSettingsList.isEmpty()) {
                return customSettingsList[0];
            }
            return null;
        } catch (Exception e) {
            new ApexLog().createLog(
                    new ApexLog.Error(
                            'CustomSettingsManagementController',
                            'getSettings',
                            null,
                            e
                    )
            );
            throw new AuraHandledException('Error when selecting custom settings values.');
        } finally {
            ApexLog.commitLogs();
        }
    }

    /**
     * @description retrieves specified custom settings for current user, if user specific custom settings dont exist
     * retrieves org defaults instead
     *
     * @param customSettingsApiName API name of custom settings
     *
     * @return custom settings with all its fields for specified user or org defaults
     */
    @AuraEnabled
    public static SObject getSettingsForSpecificUser(String customSettingsApiName) {
        try {
            if (customSettingsApiName == null) {
                throw new Exceptions.BadDataException('customSettingsApiName cannot be null');
            }
            final String soqlTemplate = 'SELECT {0} FROM {1} WHERE SetupOwnerId = {2}';
            Set<String> fieldNames = Schema.describeSObjects(new String[]{
                    customSettingsApiName
            })[0].fields.getMap().keySet();
            List<String> iterableFields = new List<String>(fieldNames);
            List<SObject> customSettingsList = Database.query(
                    String.format(soqlTemplate,
                            new String[]{
                                    String.join(iterableFields, ','), customSettingsApiName, '\'' + UserInfo.getUserId() + '\''
                            })
            );
            if (!customSettingsList.isEmpty()) {
                return customSettingsList[0];
            }
            customSettingsList = Database.query(
                    String.format(soqlTemplate,
                            new String[]{
                                    String.join(iterableFields, ','), customSettingsApiName, '\'' + UserInfo.getOrganizationId() + '\''
                            })
            );
            if (!customSettingsList.isEmpty()) {
                return customSettingsList[0];
            }
            return null;
        } catch (Exception e) {
            new ApexLog().createLog(
                    new ApexLog.Error(
                            'CustomSettingsManagementController',
                            'getSettingsForSpecificUser',
                            null,
                            e
                    )
            );
            throw new AuraHandledException('Error when selecting custom settings values.');
        } finally {
            ApexLog.commitLogs();
        }
    }

    /**
     * @description saves provided custom settings, if provided custom settings are not specific for current user,
     * creates user specific one
     *
     * @param customSettings custom settings to save
     *
     */
    @AuraEnabled
    public static void saveSettingsForCurrentUser(SObject customSettings) {
        try {
            if (customSettings == null) {
                throw new Exceptions.BadDataException('Custom settings cannot be null');
            }
            if (customSettings.get('SetupOwnerId') == UserInfo.getUserId()) {
                update customSettings;
            } else {
                SObject newSettings = customSettings.clone(false);
                newSettings.put('SetupOwnerId', UserInfo.getUserId());
                insert newSettings;
            }
        } catch (Exception e) {
            new ApexLog().createLog(
                    new ApexLog.Error(
                            'CustomSettingsManagementController',
                            'saveSettingsForCurrentUser',
                            null,
                            e
                    )
            );
            throw new AuraHandledException('Error when saving custom settings values.');
        } finally {
            ApexLog.commitLogs();
        }
    }

    /**
     * @description saves provided custom settings
     *
     * @param customSettings custom settings to save
     *
     */
    @AuraEnabled
    public static void saveOrgDefaultSettings(SObject customSettings) {
        try {
            if (customSettings == null) {
                throw new Exceptions.BadDataException('Custom settings cannot be null');
            }
            customSettings.put('SetupOwnerId', UserInfo.getOrganizationId());
            update customSettings;
        } catch (Exception e) {
            new ApexLog().createLog(
                    new ApexLog.Error(
                            'CustomSettingsManagementController',
                            'saveOrgDefaultSettings',
                            null,
                            e
                    )
            );
            throw new AuraHandledException('Error when saving custom settings values.');
        } finally {
            ApexLog.commitLogs();
        }
    }
}