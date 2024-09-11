import { LightningElement,api } from 'lwc';

export default class OpportunityKeyDetails extends LightningElement {


@api selectedStage;
@api recordData;
 fields = [];
 fields1 = [];
 fields2 = [];
 fields3 = [];
 fields4 = [];
 fields5 = [];
    // Flexipage provides recordId and objectApiName
@api recordId;
@api objectApiName;
showData = false;
showSpinner = false;

stageField = 'StageName';
notes_FIELD = 'Notes__c';
leadSource_FIELD = 'LeadSource';
useCase_FIELD = 'Use_Case__c';
totalYear1_FIELD = 'Total_Year_1__c';
nextStep_FIELD = 'NextStep';
closeDate_FIELD = 'CloseDate';
arr_FIELD = 'ARR__c';
exitCriteria =[];
showExitCrtiteria = false;

discoveryAndQualificationExitCriteria =[
  {
      id:"1",
      criteria:"Identification of key decision-makers and influencers."
  },{
      id:"2",
      criteria:"Understanding of the prospect's strategic objectives and challenges."
  },{
      id:"3",
      criteria:"Initial alignment of our solution with prospect needs."    
  }, {
      id:"4",
      criteria:"Understanding of the prospect’s decision-making criteria."    
  }, 
 
];

engageAndAssessExitCriteria =[
  {
      id:"1",
      criteria:"Clear understanding of the prospect's buying process and timeline."
  },{
      id:"2",
      criteria:"Agreement and alignment on mutual accountabilities (business case build, economic value inputs, etc.)"
  },{
      id:"3",
      criteria:"Economic value calculator completed and presented."    
  }, {
      id:"4",
      criteria:"Formal proposal requested."    
  }, 
 
];

proposalAndNegotiationExitCriteria = [
 {
      id:"1",
      criteria:"Proposal reviewed and accepted by all stakeholders"
 },{
      id:"2",
      criteria:"Clear agreement on timelines and next steps."
 },{
      id:"3",
      criteria:"Proposal validated against internal business case framework."
 },{
      id:"4",
      criteria:"Final validation of ROI and solution fit."
 },{
      id:"5",
      criteria:"Contract requested"
  }, 
];

contractingAndClosureExitCriteria =[
{
      id:"1",
      criteria:"Agreement on contract terms and conditions."
},{
      id:"2",
      criteria:"Signed contract received from all parties."
},{
      id:"3",
      criteria:"Agreement on the implementation process and next steps.",
  }, 
];

closeExitCriteria =[
{
      id:"1",
      criteria:"Successful customer handoff via kickoff call and follow-up."
},{
      id:"2",
      criteria:"A clear understanding of the next steps in the customer journey."
},
]

connectedCallback() {
    this.updateKeyFields(this.selectedStage);
}

@api updateKeyFields(selectedValue){
    //this.showSpinner = true;
            this.fields = [];
            this.exitCriteria=[];
        if(selectedValue == 'Discovery and Qualification'){
            this.fields.push(this.leadSource_FIELD,this.nextStep_FIELD,this.notes_FIELD,this.useCase_FIELD,this.totalYear1_FIELD);
            this.exitCriteria=this.discoveryAndQualificationExitCriteria;
        }
        else if(selectedValue == 'Engage and Assess'){
            this.fields.push(this.notes_FIELD,this.nextStep_FIELD,this.totalYear1_FIELD);
            this.exitCriteria = this.engageAndAssessExitCriteria;
        }
        else if(selectedValue == 'Proposal and Negotiation'){
            this.fields.push(this.closeDate_FIELD,this.notes_FIELD,this.nextStep_FIELD,this.arr_FIELD,this.totalYear1_FIELD);
            this.exitCriteria=this.proposalAndNegotiationExitCriteria;
        }
        else if(selectedValue == 'Contracting & Closure'){
            this.fields.push(this.notes_FIELD,this.nextStep_FIELD,this.totalYear1_FIELD);
            this.exitCriteria=this.contractingAndClosureExitCriteria;

        }
        else if(selectedValue == 'Closed'){
            this.fields.push(this.notes_FIELD,this.nextStep_FIELD,this.totalYear1_FIELD);
            this.exitCriteria=this.closeExitCriteria;
        }
        else{
            this.showData = false;
            this.fields = [];
            this.exitCriteria=[];
        }

        if(this.fields.length >0){

            if(this.exitCriteria.length>0){
                this.showData =true;
                this.showExitCrtiteria = true;
                // console.log('fields:'+JSON.stringify(this.fields))
                // console.log('exitCriteria:'+JSON.stringify(this.exitCriteria))
            }else{
                this.showData =true;
                this.showExitCrtiteria = false;
            }
            

        }else{
            this.showData =false;
            this.fields = [];
            this.showSpinner = false;
        }
    }
}