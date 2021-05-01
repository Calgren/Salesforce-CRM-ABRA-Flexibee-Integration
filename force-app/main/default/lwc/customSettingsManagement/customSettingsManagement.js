/**
 * Allows user to create/update hierarchical custom settings for current user.
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-01
 */
import {LightningElement, api, wire, track} from 'lwc';
import {getObjectInfo} from "lightning/uiObjectInfoApi";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getSettings from '@salesforce/apex/CustomSettingsManagementController.getSettings';
import saveOrgDefaultSettings from '@salesforce/apex/CustomSettingsManagementController.saveOrgDefaultSettings';
import isAbraFlexiAppAdmin from '@salesforce/customPermission/ABRA_Flexi_App_Admin';

import SettingsSaved from '@salesforce/label/c.SettingsSaved';

export default class CustomSettingsManagement extends LightningElement {

    @api settingsApiName;

    labels = {
        Save: 'Save'
    };
    @track customSettings;

    @track settingsObjectInfo;

    @wire(getObjectInfo, {objectApiName: '$settingsApiName'})
    getSettingsObjectInfo({error, data}) {
        if (data) {
            this.settingsObjectInfo = data;
            this.settingsCustomFields;
        } else if (error) {
            //processError(this, error);
        }
    }

    _hasRendered;
    /**
     * loads all data for component
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-04-08
     */
    async renderedCallback() {
        if (this._hasRendered) {
            return;
        }
        try {
            this._hasRendered = true;
            //await showSpinner(this);
            await this.init();
        } catch (e) {
            //processError(this, e);
        } finally {
            //hideSpinner(this);
        }
    }

    /**
     * if custom settings api name is provided - fetches settings
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-04-08
     */
    async init() {
        if (this.settingsApiName) {
            this.customSettings = await getSettings({customSettingsApiName: this.settingsApiName});
        }
    }

    /**
     * display component if all essential variables all loaded
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-04-08
     */
    get allLoaded() {
        return Boolean(this.settingsObjectInfo);
    }

    /**
     * creates list of custom settings custom fields definitions with values for markup to be rendered
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-04-08
     */
    get settingsCustomFields() {
        if (this.settingsObjectInfo) {
            const customFieldsDefinitions = Object.values(this.settingsObjectInfo.fields)
                .filter(fieldDefinition => fieldDefinition.apiName.endsWith('__c'));
            return customFieldsDefinitions.map(fieldDefinition => {
                const fieldDefinitionCopy = JSON.parse(JSON.stringify(fieldDefinition));
                if (this.customSettings) {
                    fieldDefinitionCopy.value = this.customSettings[fieldDefinitionCopy.apiName];
                }
                switch (fieldDefinitionCopy.dataType) {
                    case 'Boolean':
                        fieldDefinitionCopy.type = 'checkbox';
                        fieldDefinitionCopy.required = false;
                        break;
                    case 'String':
                        fieldDefinitionCopy.type = 'text';
                        fieldDefinitionCopy.maxLength = fieldDefinitionCopy.length;
                        break;
                    case 'Double':
                        fieldDefinitionCopy.type = 'number';
                        fieldDefinitionCopy.step = Math.pow(10, -fieldDefinitionCopy.scale);
                        break;
                    case 'Date':
                        fieldDefinitionCopy.type = 'date';
                        break;
                    case 'DateTime':
                        fieldDefinitionCopy.type = 'datetime';
                        break;
                    default:
                        fieldDefinitionCopy.isText = true;
                }
                return fieldDefinitionCopy;
            });
        }
    }

    /**
     * handles value change - assigns value to custom settings
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-04-08
     */
    handleFieldValueChange(evt) {
        let value = evt.detail.value;
        if (!value) {
            value = evt.detail.checked;
        }
        this.customSettings[evt.target.name] = value;
    }

    /**
     * validates all inputs and saves custom settings if all valid
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-04-08
     */
    async handleSave() {
        try {
            const allInputsValid = [...this.template.querySelectorAll('lightning-input')]
                .reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }, true);
            if (!allInputsValid) {
                return;
            }
            //await showSpinner(this);
            await saveOrgDefaultSettings({customSettings: this.customSettings});
            const evt = new ShowToastEvent({
                title: SettingsSaved,
                variant: 'success',
            });
            this.dispatchEvent(evt);
            await this.init();
        } catch (e) {
            //processError(this, e);
        } finally {
            //hideSpinner(this);
        }
    }

    get inputsDisabled() {
        return Boolean(!isAbraFlexiAppAdmin);
    }

}