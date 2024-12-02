import { LightningElement,api,wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OpportunityScore_ID_FIELD from '@salesforce/schema/Opportunity_Scores__c.Id';
import OpportunityScore_Answer_FIELD from '@salesforce/schema/Opportunity_Scores__c.Answers__c';
import OpportunityScore_LastScoreSet_FIELD from '@salesforce/schema/Opportunity_Scores__c.Last_Score_Set__c';
import OpportunityScore_Notes_FIELD from '@salesforce/schema/Opportunity_Scores__c.Notes__c';
import { refreshApex } from '@salesforce/apex';
import getOpportunityQuestions from '@salesforce/apex/OpportunityController.getOpportunityQuestions';

export default class OpportunityScoringSection extends LightningElement {

    @api recordId;
    opportunityQuestions;
    error;
    hasOppRecords;
    showLoading = false;
    oppQuestionToRefresh;
    opportunityQuestion=[];

    connectedCallback(){
        return refreshApex(this.oppQuestionToRefresh);
    }

    @wire(getOpportunityQuestions,{opportunityId : '$recordId'})
    wiredOpportunityQuestions (result) {
        // console.log('opportunityQuestions:'+JSON.stringify(result));
        this.oppQuestionToRefresh = result;
        if(result.data){
            refreshApex(this.oppQuestionToRefresh);
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

    handleQuestionUpdate(event){
        this.updateQuestionsAnswer(event.detail.scoreValue,event.detail.notesValue,event.detail.currentOppScoreId);
    }

    updateQuestionsAnswer(scoreValue,notesValue,currentOppScoreId){
        // return refreshApex(this.recordData);
        this.showLoading = true;
        var today = new Date().toISOString();
        // console.log('today: '+JSON.stringify(today));

        const fields = {};
        fields[OpportunityScore_ID_FIELD.fieldApiName] = currentOppScoreId;
        if(scoreValue !== '' && scoreValue != undefined){
            fields[OpportunityScore_Answer_FIELD.fieldApiName] = scoreValue;
            fields[OpportunityScore_LastScoreSet_FIELD.fieldApiName] = today;
        }
        if(notesValue !== '' && notesValue != undefined){
            fields[OpportunityScore_Notes_FIELD.fieldApiName] = notesValue;
        }
        const recordInput = { fields };
        // console.log('recordInput',recordInput);

        updateRecord(recordInput)
        .then(() => {
            this.showToast('Success!!', 'Score updated successfully!!', 'success', 'dismissable');
            // Display fresh data in the form
            this.showLoading = false;
            return refreshApex(this.oppQuestionToRefresh);
        })
        .catch(error => {
            this.showLoading = false;
            this.showToast('Error!!', error.body.message, 'error', 'dismissable');
        });
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

}