/**
 *
 *
 * @author  tomaschour
 * @date    2021-04-25
 */
import {LightningElement, api, wire, track} from 'lwc';

export default class AbraIntegrationOverview extends LightningElement {
    @track integrationOverviewDto;
    labels = {
        abraIntegrationOverview: 'ABRA Flexi Integration Overview'
    };

}