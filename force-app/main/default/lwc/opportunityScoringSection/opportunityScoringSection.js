import { LightningElement,api,wire } from 'lwc';
import{ refreshApex } from '@salesforce/apex';
import getOpportunityQuestions from '@salesforce/apex/OpportunityController.getOpportunityQuestions';

export default class OpportunityScoringSection extends LightningElement {

    @api recordId;
    opportunityQuestions;
    error;
    hasOppRecords;

    @wire(getOpportunityQuestions,{opportunityId : '$recordId'})
    wiredOpportunityQuestions (result) {
        // console.log('opportunityQuestions:'+JSON.stringify(result));
        if(result.data){
            this.opportunityQuestions = result.data;
            this.error = undefined;
            if(this.opportunityQuestions.length>0){
                this.hasOppRecords = true;
            }else{
                this.hasOppRecords = false;
            }
        }
        else if(result.error){
            this.opportunityQuestions=undefined;
            this.error = result.error;
            this.hasOppRecords = false;
        }
    }

}