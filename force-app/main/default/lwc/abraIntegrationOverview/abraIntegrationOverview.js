/**
 *
 *
 * @author  tomaschour
 * @date    2021-04-25
 */
import {LightningElement, api, wire, track} from 'lwc';
import getBatchRunsInfo from '@salesforce/apex/AbraIntegrationOverviewController.getBatchRunsInfo';

export default class AbraIntegrationOverview extends LightningElement {
    @track integrationOverviewDto;
    labels = {
        abraIntegrationOverview: 'ABRA Flexi Integration Overview',
        runSynchronizationNow: 'Run export now',
        lastExportRun: 'Last export run',
        nextExportRun: 'Next export run'
    };

    _hasRendered;
    /**
     * loads all data for component
     *
     * @author  tomaschour- Aspectworks
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
     * @author  tomaschour- Aspectworks
     * @date    2021-04-25
     */
    async init() {
        this.integrationOverviewDto = await getBatchRunsInfo();
    }

    get allLoaded() {
        return Boolean(this.integrationOverviewDto);
    }

    async runSync(){
        this.integrationOverviewDto.isCurrentlyRunning = true;
    }

    get syncButtonDisabled(){
        return Boolean(this.integrationOverviewDto && this.integrationOverviewDto.isCurrentlyRunning);
    }

}