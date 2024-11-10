import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
// import PICKLIST_FIELD from '@salesforce/schema/Opportunity.eVisit_Noted_Differentiators__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class OpportunityExitCriteria extends LightningElement {

    @api isShowSpinner = false;
    @api recordId;
    @api selectedStage;
    isProposalandNegotiationStage = false;
    isContractingandClosureStage = false;
    isCloseStage = false;
    @api recordData;
    openModal = false;
    stageValue = "";
    showStageModal = false;
    hideRequiredCheckboxField=false;

    options = [
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' },
    ];


    handleChangeStageModal(event) {
        this.stageValue = event.detail.value;
        // console.log('this.stageValue:'+JSON.stringify(this.stageValue))
        if (this.stageValue != "" && this.stageValue != "Closed Lost") {
            this.showStageModal = true;
            this.hideRequiredCheckboxField = false;
        }else if (this.stageValue != "" && this.stageValue == "Closed Lost") {
            this.showStageModal = true;
            this.hideRequiredCheckboxField = true;
        }
         else {
            this.showStageModal = false;
        }

        // console.log('this.eVisitDiffrentioatorValue:'+JSON.stringify(this.eVisitDiffrentioatorValue))
       
        // input.className = 'slds-combobox__input slds-input_faux fix-slds-input_faux slds-combobox__input-value';
    }

    handleChangediffrentiator(event) {
        this.eVisitDiffrentioatorValue = event.detail.value;
       
    }
    renderedCallback(){
        let input = this.template.querySelector(`[data-id="StageName"]`);
        input.value='Closed Lost';
        input.className='slds-hide'
    }

    connectedCallback() {

        //console.log('selectedStage:' + JSON.stringify(this.recordData.fields))
        if (this.selectedStage == 'Proposal and Negotiation' && this.recordData.fields.Proposal_Budget_Alignments__c.value == false) {
            this.openModal = true;
            this.isProposalandNegotiationStage = true;
            this.isContractingandClosureStage = false;
            this.isCloseStage = false;

        }
        else if (this.selectedStage == 'Contracting & Closure' && this.recordData.fields.Workflow_Diagram_SLT_Signoff__c.value == false) {
            this.openModal = true;
            this.isProposalandNegotiationStage = false;
            this.isContractingandClosureStage = true;
            this.isCloseStage = false;
        }
        else if (this.selectedStage == 'Closed' && (this.recordData.fields.All_Contract_Details_complete__c.value == false || this.recordData.fields.eVisit_Noted_Differentiators__c.value == null)) {
            this.openModal = true;
            this.isProposalandNegotiationStage = false;
            this.isContractingandClosureStage = false;
            this.isCloseStage = true;
        } else {
            this.openModal = false;
            this.updateStageWithoutCriteria(this.selectedStage);
        }
    }

    updateStageWithoutCriteria(selectedStage){
        this.dispatchEvent(new CustomEvent("save", {
                        detail: selectedStage
                    }));   
    }
    hideModalBox() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    handleSubmitExitCriteria() {
        // event.preventDefault();
        this.isShowSpinner = true;
    }

    handleUpdateStage() {
        if (this.stageValue != null && this.selectedStage == 'Closed') {
            this.dispatchEvent(new CustomEvent("save", {
                detail: this.stageValue
            }));
        } else {
            this.dispatchEvent(new CustomEvent("save", {
                detail: this.selectedStage
            }));
        }
            this.showSpinner = false;

    }

    handleError() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Failed!',
                message: 'Error updating status!',
                variant: 'error'
            })
        );
        // console.log('error:'+JSON.stringify(event.detail))
    }
}