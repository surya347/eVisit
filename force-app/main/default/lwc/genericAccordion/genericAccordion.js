import { LightningElement,api } from 'lwc';

export default class GenericAccordion extends LightningElement {

@api recordData;

connectedCallback(){
        console.log('opportunityQuestions:'+JSON.stringify(this.recordData));
}

}