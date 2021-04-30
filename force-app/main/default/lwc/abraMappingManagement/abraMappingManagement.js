/**
 *
 *
 * @author  tomaschour
 * @date    2021-04-25
 */
import {LightningElement, api, wire, track} from 'lwc';
import isAbraFlexiAppAdmin from '@salesforce/customPermission/ABRA_Flexi_App_Admin';
import {getObjectInfo} from "lightning/uiObjectInfoApi";

export default class AbraMappingManagement extends LightningElement {

    @api abraEntityApiName;
    @track sfscSObjectName = 'Invoice__c';
    @track abraEntityDefinition;
    @track mappingDtos;

    @track displaySfscFieldSelectionModal = false;

    _currentlySelectedMappingIdent;
    _currentFieldsInPath;
    _isEndFieldSelected;

    labels = {
        AddAttribute: 'Add Attribute',
        SfscAttribute: 'Salesforce Attribute API Name',
        AbraAttribute: 'Abra Attribute API Name',
        Save: 'Save',
        Mapping: 'Mapping',
        ChooseSfscField: 'Choose SObject Field',
        Cancel: 'Cancel',
        Confirm: 'Confirm',
        AttributesMapping: 'Attributes Mapping',
        SFSCToABRAFlexiSync: 'SFSC To ABRA Flexi Sync',
        ABRAFlexiToSFSCSync: 'ABRA Flexi To SFSC Sync'
    };

    @track multilevelFieldsForCombobox;
    @track multilevelSfscFieldsDefinitions

    @track sObjectInfo;

    @wire(getObjectInfo, {objectApiName: '$sfscSObjectName'})
    getSObjectInfo({error, data}) {
        if (data) {
            this.sObjectInfo = data;
            this.settingsCustomFields;
        } else if (error) {
            //processError(this, error);
        }
    }

    _hasRendered;
    /**
     * loads all data for component
     *
     * @author  tomaschour
     * @date    2021-04-25
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
     * @author  tomaschour
     * @date    2021-04-25
     */
    async init() {
        this.mappingDtos = [];
        if (this.settingsApiName) {
            //this.customSettings = await getSettings({customSettingsApiName: this.settingsApiName});
        }
    }

    /**
     * display component if all essential variables all loaded
     *
     * @author  tomaschour
     * @date    2021-04-25
     */
    get allLoaded() {
        return Boolean(true);
    }

    appendNewMapping() {
        let newMappingDto = {
            id: null,
            sfscSObjectName: this.sfscSObjectName,
            abraEntityApiName: this.abraEntityApiName,
            sfscFieldName: null,
            abraFieldName: null,
            sfscToAbraSync: false,
            abraToSfscSync: false,
            ident: Math.floor(Math.random() * 10000)
        };
        this.mappingDtos.push(newMappingDto);
    }

    get disabledMode() {
        return Boolean(!isAbraFlexiAppAdmin);
    }


    get mappingTitle() {
        if (this.sObjectInfo) {
            return this.labels.Mapping + ' for ' + this.abraEntityApiName + ' to ' + this.sObjectInfo.label;
        } else {
            return this.labels.Mapping + ' for ' + this.abraEntityApiName;
        }

    }


    handleCancel() {
        this.displaySfscFieldSelectionModal = false;
    }

    handleConfirm() {
        try {
            let chosenField = this.processFieldsInPath();
            this.mappingDtos.find(mappingDto => mappingDto.ident === this._currentlySelectedMappingIdent)
                .sfscFieldName = chosenField;
            this.displaySfscFieldSelectionModal = false;
        } catch (e) {
            console.error(e);
        }
    }

    handleDisplaySfscFieldSelectionModal(evt) {
        const mappingIdent = evt.currentTarget.dataset.rowIdent;
        this._currentlySelectedMappingIdent = Number(mappingIdent);
        this._currentFieldsInPath = [];
        this._isEndFieldSelected = false;
        this.displaySfscFieldSelectionModal = true;
    }



    /**
     *
     *
     * @author  tomaschour
     * @date    2021-04-25
     */
    get settingsCustomFields() {
        if (this.sObjectInfo) {
            this.multilevelSfscFieldsDefinitions = [];
            const customFieldsDefinitions = Object.values(this.sObjectInfo.fields);
            this.multilevelSfscFieldsDefinitions.push(JSON.parse(JSON.stringify(customFieldsDefinitions)));
            console.log('TTTT xD  xD ', JSON.parse(JSON.stringify(customFieldsDefinitions)));
            this.multilevelFieldsForCombobox = [];
            this.multilevelFieldsForCombobox.push(customFieldsDefinitions.map(fieldDefinition => ({label: fieldDefinition.label, value: fieldDefinition.apiName})));
            console.log('TTTT xD  xD2 ', JSON.parse(JSON.stringify(this.multilevelFieldsForCombobox)));
        }
    }

    handleSfccFieldComboSelection(evt) {
        const index = Number(evt.currentTarget.dataset.index);
        const fieldApiName = evt.detail.value;
        console.log('TTTT index ', index , ' ' ,fieldApiName);
        const fieldDefinition = this.multilevelSfscFieldsDefinitions[index].find(fieldDefinition => fieldDefinition.apiName === fieldApiName);
        if (fieldDefinition.dataType === 'Reference') {
            console.log('TTT is reference');
            console.log('TTTT reference object: ', fieldDefinition.referenceToInfos[0].apiName);
        } else {
            this._currentFieldsInPath.push(fieldApiName);
            this._isEndFieldSelected = true;
        }
    }

    processFieldsInPath() {
        return this._currentFieldsInPath.join('.');
    }

    get confirmDisabled() {
        return Boolean(!this._isEndFieldSelected);
    }

    handleSfscToAbraSyncChange(evt) {
        const mappingIdent = Number(evt.currentTarget.dataset.rowIdent);
        this.mappingDtos.find(mappingDto => mappingDto.ident === mappingIdent)
            .sfscToAbraSync = evt.detail.checked;
    }

    async handleSave(){
        try {
            console.log('TTT SAVING ', JSON.parse(JSON.stringify(this.mappingDtos)));
        } catch(e) {
            console.error(e);
        }
    }
}