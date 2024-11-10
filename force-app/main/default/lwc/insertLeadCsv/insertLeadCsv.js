import { LightningElement } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import readCSVFileToUpdateParentLeads from '@salesforce/apex/UploadLeadController.readCSVFileToUpdateParentLeads';
// import readCSVFileToUpdateUltimateParentLeads from '@salesforce/apex/UploadLeadController.readCSVFileToUpdateUltimateParentLeads';

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

    // handleUploadUltimateFinished(event){
    //      const uploadedFiles = event.detail.files;
    //     console.log("uploadedFiles:>"+JSON.stringify(uploadedFiles));
    //     // calling apex class
    //     readCSVFileToUpdateUltimateParentLeads({idContentDocument : uploadedFiles[0].documentId})
    //     .then(result => {
    //         window.console.log('resultS ===> '+result);
    //         this.data = result;
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Success!!',
    //                 message: 'Leads are created via CSV file!!!',
    //                 variant: 'success',
    //             }),
    //         );
    //     })
    //     .catch(error => {
    //         console.log('error:'+JSON.stringify(error))
    //         this.error = error;
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error!!',
    //                 message: JSON.stringify(error),
    //                 variant: 'error',
    //             }),
    //         );     
    //     })

    // }

}