/**
 *
 *
 * @author  tomaschour
 * @date    2021-04-25
 */
import {LightningElement, api, wire, track} from 'lwc';
import isAbraFlexiAppAdmin from '@salesforce/customPermission/ABRA_Flexi_App_Admin';
import {getObjectInfo} from "lightning/uiObjectInfoApi";
import getCurrentMappings from '@salesforce/apex/AbraMappingManagementController.getCurrentMappings';
import getAbraFields from '@salesforce/apex/AbraMappingManagementController.getAbraFields';

export default class AbraMappingManagement extends LightningElement {

    @api abraEntityApiName;
    @api entityNameToGetSchemaFrom;
    @track sfscSObjectName;
    @track abraFieldOptions;
    @track mappingDtos;
    @track mappingIdsToDelete;

    @track displaySfscFieldSelectionModal = false;
    @track sObjectOptions = [{label:'Invoice', value: 'Invoice__c'}, {label:'Order', value: 'Order'}]

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
        ABRAFlexiToSFSCSync: 'ABRA Flexi To SFSC Sync',
        ChooseSObject: 'Choose SObject',
        ChangeSObject: 'Change SObject',
        ConfirmSObjectChange_Msg: 'Do you really wish to change object a remove all current mappings?'
    };

    @track multilevelFieldsForCombobox;
    @track multilevelSfscFieldsDefinitions

    @track sObjectInfo;

    @wire(getObjectInfo, {objectApiName: '$sfscSObjectName'})
    getSObjectInfo({error, data}) {
        if (data) {
            console.log('TTTSAfsASFFSA ASfaFAS')
            this.sObjectInfo = data;
            this.settingsCustomFields;
        } else if (error) {
            console.error(error);
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
        if (this.abraEntityApiName) {
            this.mappingIdsToDelete = [];
            let abraFieldMappingDto;
            [this.mappingDtos, abraFieldMappingDto] = await Promise.all([
                getCurrentMappings({abraEntityName: this.abraEntityApiName}),
                getAbraFields({abraEntityName: this.abraEntityApiName})
            ])

            console.log('TTTT HJERE00', JSON.parse(JSON.stringify(abraFieldMappingDto)));
            this.abraFieldOptions = Object.keys(abraFieldMappingDto.abraEntityAttributes).map(fieldName => ({label: fieldName, value: fieldName}));
            if (this.mappingDtos.length > 0) {
                console.log('TTTT HJERE0');
                this.sfscSObjectName = this.mappingDtos[0].sfscSObjectName;
                console.log('TTTT HJERE1');
            }
        }
    }

    /**
     * display component if all essential variables all loaded
     *
     * @author  tomaschour
     * @date    2021-04-25
     */
    get allLoaded() {
        console.log('TTTT LALA ', Boolean(this.mappingDtos));
        return Boolean(this.mappingDtos);
    }

    appendNewMapping() {
        let newMappingDto = {
            recordId: null,
            sfscSObjectName: this.sfscSObjectName,
            abraEntityApiName: this.abraEntityApiName,
            sfscFieldName: null,
            abraFieldName: null,
            sfscToAbraSync: false,
            abraToSfscSync: false,
            ident: (Math.floor(Math.random() * 10000)).toString()
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
        this._currentlySelectedMappingIdent = mappingIdent;
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
        const mappingIdent = evt.currentTarget.dataset.rowIdent;
        this.mappingDtos.find(mappingDto => mappingDto.ident === mappingIdent)
            .sfscToAbraSync = evt.detail.checked;
    }

    handleAbraToSfscSyncChange(evt) {
        const mappingIdent = evt.currentTarget.dataset.rowIdent;
        this.mappingDtos.find(mappingDto => mappingDto.ident === mappingIdent)
            .abraToSfscSync = evt.detail.checked;
    }

    handleAbraFieldChange(evt) {
        const mappingIdent = evt.currentTarget.dataset.rowIdent;
        console.log('TTTT mappingIdent ' ,mappingIdent );
        this.mappingDtos.find(mappingDto => mappingDto.ident === mappingIdent)
            .abraFieldName = evt.detail.value;
    }

    async handleSave(){
        try {
            console.log('TTT SAVING ', JSON.parse(JSON.stringify(this.mappingDtos)));
        } catch(e) {
            console.error(e);
        }
    }

    handleChangeSObject(evt) {
        this.sfscSObjectName = evt.detail.value;
    }

    async changeSObjectClick(){
        const confirmationComponent = this.findElementByClass('confirmPopup');
        let confirmed = await confirmationComponent.awaitConfirmation(this.labels.ConfirmSObjectChange_Msg);
        if (!confirmed) {
            return;
        }
        this.deleteAllMappings();
        this.sfscSObjectName = null;
        this.multilevelSfscFieldsDefinitions = null;
    }

    deleteAllMappings() {
        this.mappingDtos.forEach(mappingDto => {
            if(mappingDto.recordId) {
                this.mappingIdsToDelete.push(mappingDto.recordId);
            }
        });
        this.mappingDtos = [];
    }

    findElementByClass(className) {
        return this.template.querySelector('.' + className);
    }

    get displayAttributesMappingSection(){
        return Boolean(this.sfscSObjectName && this.multilevelSfscFieldsDefinitions);
    }
}