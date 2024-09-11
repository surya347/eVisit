/* eslint-disable no-console */
// Import LightningElement and api classes from lwc module
import { LightningElement, api, wire, track } from 'lwc';
// import getPicklistValues method from lightning/uiObjectInfoApi
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import getObjectInfo method from lightning/uiObjectInfoApi
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// Import Opportunity object APi from schema
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
// import Opportunity status field from schema
import PICKLIST_FIELD from '@salesforce/schema/Opportunity.StageName';
import { getRecord, createRecord } from 'lightning/uiRecordApi';
// import show toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import update record api
import { updateRecord } from 'lightning/uiRecordApi';
import getRecordDetails from '@salesforce/apex/OpportunityController.getRecordDetails';
import getStageNames from '@salesforce/apex/OpportunityController.getStageNames';

const FIELDS = [
    'Opportunity.Id',
    'Opportunity.StageName',
    'Opportunity.Proposal_Budget_Alignments__c',
    'Opportunity.Exec_Sponsor_Identified__c',
    'Opportunity.Custom_Demo_Completed__c',
    'Opportunity.Workflow_Diagram_SLT_Signoff__c',
    'Opportunity.Integrations_Diagram_SLT_Signoff__c',
    'Opportunity.Articulated_SOW_SLT_Signoff__c',
    'Opportunity.Pricing_Approval_SLT_Signoff__c',
    'Opportunity.All_Contract_Details_complete__c',
    'Opportunity.Billing_Contact_identified__c',
    'Opportunity.PO_Populated__c',
    'Opportunity.eVisit_Noted_Differentiators__c'
];

export default class OpportunityStagingPath extends LightningElement {

    @api recordId;
    showSpinner = false;
    isModalOpen = false;
    selectedValue;
    currentStage;
    iconName = "utility:chevronright";
    showKeyDetails = false;
    picklist;
    opportunityPicklistValues = [];
    opportunityPicklistValuesArray = [];
    recordData;
    showPath = false;

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    objectInfo;

     @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
     recordss({data,error}){
         if(data){
             this.recordData = data;
            this.currentStage = data.fields.StageName.value;
           // console.log("this.currentStage:" + JSON.stringify(this.currentStage));
         }
         else if(error){
                console.log("error:" + JSON.stringify(error));
         }
     }

     @wire(getStageNames,{currentStage : '$currentStage',objectNames:'Opportunity',fieldNames:'StageName'})
     wiredStageNames({data,error}){
         if(data){
             let stageArr =data;
             var valueToSplit ;
             let arr = [];
             let arr2 = [];
             for (var i = 0; i < stageArr.length; i++) {
                    valueToSplit = stageArr[i].split('=');
                    if(valueToSplit[0] == 'Closed Won' || valueToSplit[0] == 'Closed Lost'){
                         arr.push({ label: "Closed", value: "Closed"})
                         arr2.push("Closed");
                         break;
                    }else{
                        arr.push({ label: valueToSplit[0], value: valueToSplit[1]})
                        arr2.push(valueToSplit[1]);
                    }
                   
                }
             this.opportunityPicklistValues = arr;
            //  console.log('this.opportunityPicklistValues:' + JSON.stringify(this.opportunityPicklistValues))
             this.opportunityPicklistValuesArray = arr2;
            //  console.log('this.opportunityPicklistValuesArray:' + JSON.stringify(this.opportunityPicklistValuesArray))
             this.getRecordsData();
         }
          else if (error) {
                console.log("error:" + JSON.stringify(error));
            }
     }


  getRecordsData(){
            getRecordDetails({ recordIds: this.recordId})
                .then(result => {
                    if (result != null) {
                        this.selectedValue = result;
                        if(result == 'Closed Won' || result =='Closed Lost'){
                            this.currentStage = "Closed";
                        }else{
                            this.currentStage = result;
                        }
                         let classToRemove = this.template.querySelector('.slds-is-active');
                         if (classToRemove) {
                                classToRemove.className = 'slds-path__item slds-is-incomplete';
                        }
                        var stage = this.template.querySelector(`[data-id="${this.currentStage}"]`);
                        if (stage) {
                            // console.log('yes')
                            stage.className = 'slds-path__item slds-is-active';
                            this.applyCustomCss(this.currentStage);
                            this.showSpinner = false;
                        } else {
                            // console.log('no')
                            this.showSpinner = false;
                        }
                    }
                })
                .catch(error => {
                    console.log("record error:" + JSON.stringify(error));
                })
        }


        handleClickIcon(event){
            let currentIcon = event.currentTarget.dataset.name;
            //console.log('currentIcon:' + JSON.stringify(currentIcon))

            let isNewActionIcon = this.template.querySelector(`[data-name=${currentIcon}]`);
            if (isNewActionIcon.iconName == 'utility:chevronright') {
                this.template.querySelector(`[data-name=${currentIcon}]`).iconName = 'utility:chevrondown';
                this.showKeyDetails = true;
            } else {
                this.template.querySelector(`[data-name=${currentIcon}]`).iconName = 'utility:chevronright';
                this.showKeyDetails = false;
            }


        }

       
        handleSelect(event) {
            this.selectedValue = event.currentTarget.dataset.id;
            console.log(' this.selectedValue:' + JSON.stringify(this.selectedValue))
            
            let classToRemove = this.template.querySelector('.slds-is-active');
            if (classToRemove) {
                classToRemove.className = 'slds-path__item slds-is-incomplete';
                this.applyCustomCss(this.currentStage);
            }
            this.template.querySelector(`[data-id="${this.selectedValue}"]`).className = 'slds-path__item slds-is-active';
            if(this.selectedValue == this.currentStage){
                this.template.querySelector(`[data-id="${this.currentStage}"]`).className = 'slds-path__item slds-is-active';
            }else{
                 this.template.querySelector(`[data-id="${this.currentStage}"]`).className = 'slds-path__item slds-is-current';
            }
            this.template.querySelector('c-opportunity-key-details').updateKeyFields(this.selectedValue);

        }

        applyCustomCss(currentStage){
            this.removeAllCssClass();
            for (var i = 0; i < this.opportunityPicklistValuesArray.length; i++) {
                if (this.opportunityPicklistValuesArray[i] == currentStage) {
                    break;
                } else {
                    this.template.querySelector(`[data-id="${this.opportunityPicklistValuesArray[i]}"]`).className = 'slds-path__item slds-is-complete';
                }
            }

        }

        removeAllCssClass(){
                let completeClasses = this.template.querySelectorAll('.slds-is-complete');
                   if(completeClasses.length>0){
                       for(var i=0;i<completeClasses.length;i++){
                           completeClasses[i].className = 'slds-path__item slds-is-incomplete'
                       }
                   }

                   let currentClass = this.template.querySelectorAll('.slds-is-current');
                   if(currentClass.length>0){
                       for(var i=0;i<currentClass.length;i++){
                           currentClass[i].className = 'slds-path__item slds-is-incomplete'
                       }
                   }
                }


        handleMarkAsSelected() {
            if (this.selectedValue == 'Proposal and Negotiation' || this.selectedValue == 'Contracting & Closure' || this.selectedValue == 'Closed') {
                // console.log('this.selectedValue handleMarkAsSelected:' + JSON.stringify(this.selectedValue));
                this.isModalOpen = true;
            } 
            else {
                this.isModalOpen = false;
                this.updateOpportunityStage(this.selectedValue);
            }
        }

        handleSubmitExitCriteria(event){
            // console.log('value from chil:'+JSON.stringify(event.detail))
            this.isModalOpen = false;
            this.updateOpportunityStage(event.detail);
        }

        updateOpportunityStage(selectedStageValue){
            this.showSpinner = true;
            const fields = {};
            fields.Id = this.recordId;
            fields.StageName = selectedStageValue;

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    // this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Stage Updated!',
                            variant: 'success'
                        })
                    );
                })
                .catch(
                    error => {
                        console.log('error:'+JSON.stringify(error));
                        let errorMsg;
                        if(error.body.output.fieldErrors.StageName !=undefined){
                            errorMsg = error.body.output.fieldErrors.StageName[0].message;
                        }
                        else if(error.body.output.fieldErrors.eVisit_Noted_Differentiators__c !=undefined){
                            errorMsg = error.body.output.fieldErrors.eVisit_Noted_Differentiators__c[0].message;
                        }else{
                            errorMsg = error.body.message;
                        }
                        this.showSpinner = false;
                        this.getRecordsData();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error updating status!',
                                message: errorMsg,
                                variant: 'error'
                            })
                        );
                        // console.log('failure => ' + error.body.output.errors[0].message);
                    }
                );
            this.isModalOpen = false;
        }

        closeModal(){
            this.isModalOpen = false;
        }



    }