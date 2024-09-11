import { LightningElement } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSVFileToUpdateParentLeads from '@salesforce/apex/UploadLeadController.readCSVFileToUpdateParentLeads';
import updateLeadsWithDefinitive from '@salesforce/apex/UploadLeadController.updateLeadsWithDefinitive';

export default class InsertLeadCsv extends LightningElement {

    error;
    // columns = columns;
    data;

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log("uploadedFiles:>"+JSON.stringify(uploadedFiles));
        // calling apex class
        readCSVFileToUpdateParentLeads({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Leads are created via CSV file!!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            console.log('error:'+JSON.stringify(error))
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );     
        })

    }

    handleUploadDefinitiveLead(event){

        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log("uploadedFiles:>"+JSON.stringify(uploadedFiles));
        // calling apex class
        updateLeadsWithDefinitive({idContentDocument : uploadedFiles[0].documentId})
        .then(result => {
            window.console.log('result ===> '+result);
            this.data = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Leads are updated via CSV file!!!',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            console.log('error:'+JSON.stringify(error))
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );     
        })

    }

}