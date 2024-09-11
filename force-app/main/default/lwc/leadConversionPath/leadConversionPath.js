/* eslint-disable no-console */
// Import LightningElement and api classes from lwc module
import { LightningElement, api, wire, track } from 'lwc';
// import getPicklistValues method from lightning/uiObjectInfoApi
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import getObjectInfo method from lightning/uiObjectInfoApi
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// Import lead object APi from schema
import LEAD_OBJECT from '@salesforce/schema/Lead';
// import Lead status field from schema
import PICKLIST_FIELD from '@salesforce/schema/Lead.Status';
// import record ui service to use crud services
import { getRecord,createRecord  } from 'lightning/uiRecordApi';
// import show toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import update record api
import { updateRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import NAME_FIELD from "@salesforce/schema/Account.Name";
import convertLeadToAccount from '@salesforce/apex/LeadConversion.convertLeadToAccount';
import getStageNames from '@salesforce/apex/OpportunityController.getStageNames';
import getRecordDetails from '@salesforce/apex/LeadConversion.getRecordDetails';


const FIELDS = [
    'Lead.Id',
    'Lead.Status',
    'Lead.Company',
    'Lead.Parent_Lead__c',
    'Lead.Parent_Lead__r.Company',
    'Lead.Ultimate_Parent_Lead__c',
    'Lead.Ultimate_Parent_Lead__r.Company',
];

export default class LeadConversionPath extends LightningElement {

    selectedValue='';
    selectedCompanyValue;
    selectedParentLeadId;
    selectedParentLeadCompany;
    selectedUltimateParentLeadId;
    selectedUltimateParentLeadCompany;
    relatedContacts;
    relatedParentContacts;
    relatedUltimateParentContacts;
    error;
    parnterror;
    @api recordId;
    showSpinner = false;
    isModalOpen = false;
    childSpinner=false;
    recordData;
    currentStage;
    leadPicklistValues=[];
    leadPicklistValuesArray=[];

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objectInfo;


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
     recordss({data,error}){
         if(data){
             this.recordData = data;
             this.currentStage = this.recordData.fields.Status.value;

              this.selectedCompanyValue= this.recordData.fields.Company.value;
                let parentLead = this.recordData.fields.Parent_Lead__c.value;
                let ultimateparentLead = this.recordData.fields.Ultimate_Parent_Lead__c.value;
               

                if(ultimateparentLead != null || ultimateparentLead != undefined){
                    this.selectedUltimateParentLeadId = this.recordData.fields.Ultimate_Parent_Lead__c.value;
                    this.selectedUltimateParentLeadCompany = this.recordData.fields.Ultimate_Parent_Lead__r.value.fields.Company.value;
                    // console.log('ultimateparentLead:'+JSON.stringify(this.selectedUltimateParentLeadCompany));
                }else{
                    this.selectedUltimateParentLeadId = null;
                    this.selectedUltimateParentLeadCompany = null;
                }

                if(parentLead != null || parentLead != undefined){
                    this.selectedParentLeadId = this.recordData.fields.Parent_Lead__c.value;
                    this.selectedParentLeadCompany = this.recordData.fields.Parent_Lead__r.value.fields.Company.value;
                    // console.log('selectedParentLeadCompany:'+JSON.stringify(this.selectedParentLeadCompany));

                }else{
                    this.selectedParentLeadId = null;
                    this.selectedParentLeadCompany = null;
                }

         }
         else if(error){
                console.log("error:" + JSON.stringify(error));
         }
     }

     @wire(getStageNames,{currentStage : '$currentStage',objectNames:'Lead',fieldNames:'Status'})
     wiredStageNames({data,error}){
         if(data){
             let stageArr =data;
             var valueToSplit ;
             let arr = [];
             let arr2 = [];
             for (var i = 0; i < stageArr.length; i++) {
                    valueToSplit = stageArr[i].split('=');
                    arr.push({ label: valueToSplit[0], value: valueToSplit[1]})
                    arr2.push(valueToSplit[1]);
                }
             this.leadPicklistValues = arr;
            //  console.log('this.leadPicklistValues:' + JSON.stringify(this.leadPicklistValues))
             this.leadPicklistValuesArray = arr2;
            // console.log('this.leadPicklistValuesArray:' + JSON.stringify(this.leadPicklistValuesArray))
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
                        this.currentStage = result;
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

    handleSelect(event) {
            this.selectedValue = event.currentTarget.dataset.id;
            // console.log(' this.selectedValue:' + JSON.stringify(this.selectedValue))
            // console.log(' this.currentStage:' + JSON.stringify(this.currentStage))
            
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
        }

     applyCustomCss(currentStage){
            this.removeAllCssClass();
            for (var i = 0; i < this.leadPicklistValuesArray.length; i++) {
                if (this.leadPicklistValuesArray[i] == currentStage) {
                    break;
                } else {
                    this.template.querySelector(`[data-id="${this.leadPicklistValuesArray[i]}"]`).className = 'slds-path__item slds-is-complete';
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

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Contacts__r',
        fields: ['Contact.Name','Contact.Id','Contact.Email'],
        sortBy: ['Contact.Name']
      })
      wiredContacts({ error, data }) {
        if (data) {
          this.relatedContacts = data.records;
        //   console.log('this.relatedContacts:'+JSON.stringify(this.relatedContacts));
          this.error = undefined;
        } else if (error) {
          this.error = error;
          this.relatedContacts = undefined;
          console.log('error:'+JSON.stringify(error));
        }
      }

      @wire(getRelatedListRecords, {
        parentRecordId: '$selectedParentLeadId',
        relatedListId: 'Contacts__r',
        fields: ['Contact.Name','Contact.Id','Contact.Email'],
        sortBy: ['Contact.Name']
      })

      wiredParentContacts({ error, data }) {
        if (data) {
          this.relatedParentContacts = data.records;
        //   console.log('this.relatedParentContacts:'+JSON.stringify(this.relatedParentContacts));
          this.parnterror = undefined;
        } else if (error) {
          this.parnterror = error;
          this.relatedParentContacts = undefined;
          console.log('parnt error:'+JSON.stringify(error));
        }
      }


      @wire(getRelatedListRecords, {
        parentRecordId: '$selectedUltimateParentLeadId',
        relatedListId: 'Contacts__r',
        fields: ['Contact.Name','Contact.Id','Contact.Email'],
        sortBy: ['Contact.Name']
      })

      wiredUltimateParentContacts({ error, data }) {
        if (data) {
          this.relatedUltimateParentContacts = data.records;
        //   console.log('relatedUltimateParentContacts:'+JSON.stringify(this.relatedUltimateParentContacts));
        //   this.parnterror = undefined;
        } else if (error) {
        //   this.parnterror = error;
          this.relatedUltimateParentContacts = undefined;
          console.log('ultimate parnt error:'+JSON.stringify(error));
        }
      }


    handleMarkAsSelected() {
        if(this.selectedValue == 'New Opportunity'){
            this.isModalOpen = true;
        }else{
            this.isModalOpen = false;
            this.updateLeadStatus();    
        }
       
    }

    updateLeadStatus(){
        this.showSpinner = true;
        const fields = {};
        fields.Id = this.recordId;
        fields.Status = this.selectedValue;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
            this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Status Updated!',
                        variant: 'success'
                    })
                );
            })
            .catch(
                error => {
                 this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating status!',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    console.log('failure => ' + error.body.message);
                }
            );
        this.isModalOpen=false;
    }

    closeModal(){
        this.isModalOpen = false;
    }

  
    handleConverLead(event){
        this.showSpinner =true;
        let relatedContactsId = event.detail.contactIds;
        let relatedParentContactId = event.detail.parentContactIds;
        let relatedUltimateParentContactsIds = event.detail.ultimateParentContactsId;


        convertLeadToAccount({leadRecordId:this.recordId, leadName:this.selectedCompanyValue, parentLeadRecordId:this.selectedParentLeadId,
            parentLeadName : this.selectedParentLeadCompany, ultimateParentLeadRecordId:this.selectedUltimateParentLeadId, 
            ultimateParentLeadName:this.selectedUltimateParentLeadCompany,parentUltimateContactIds:relatedUltimateParentContactsIds,
            parentContactIds:relatedParentContactId, contactIds:relatedContactsId})
            .then(result =>{
                  if(result == 'Account Created'){
                            this.showToastNotification('Success',result,'Success');
                            this.updateLeadStatus();
                            this.isModalOpen = false;
                        }else{
                            this.showToastNotification('Error creating record',result,'error');
                             this.isModalOpen = false;
                             this.showSpinner =false;
                        }
                    })
            .catch(error=>{
                            this.showToastNotification('Error creating record',error.body.message,'error');
                            this.isModalOpen = false;
                            this.showSpinner =false;
                    })
    }

    showToastNotification(title,message,variant){
         this.dispatchEvent(
            new ShowToastEvent({
              title: `${title}`,
              message: `${message}`,
              variant:`${variant}`,
            }),
          );
        
    }
}