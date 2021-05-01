/**
 * Common Container for Confirmation
 * allows to pause code execution until user confirms or rejects action by clicking on one of button in modal
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-03-26
 */
import {track, api, LightningElement} from 'lwc';
import Confirm from '@salesforce/label/c.Confirm';
import Cancel from '@salesforce/label/c.Cancel';
import Confirmation from '@salesforce/label/c.Confirmation';

export default class ConfirmationPopup extends LightningElement {

    labels = {
        Confirmation,
        Cancel,
        Confirm
    };

    @track isOpen = false;
    @api message;

    thePromise;

    /**
     * displays modal with provided message and returns unresolved promise which is resolved by clicking on cancel or confirm button
     *
     * @param {String} message - text to display in modal
     *
     * @return {Promise} unresolved promise
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-03-29
     */
    @api
    async awaitConfirmation(message) {
        this.isOpen = true;
        this.message = message;
        let res, rej;

        this.thePromise = new Promise((resolve, reject) => {
            res = resolve;
            rej = reject;
        });

        this.thePromise.resolve = res;
        this.thePromise.reject = rej;

        return this.thePromise;
    }

    /**
     * resolves promise with true value
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-03-29
     */
    handleConfirm(){
        this.thePromise.resolve(true);
        this.isOpen = false;
    }

    /**
     * resolves promise with false value
     *
     * @author  tomaschour- Aspectworks
     * @date    2021-03-29
     */
    handleCancel(){
        this.thePromise.resolve(false);
        this.isOpen = false;
    }
}