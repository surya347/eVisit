import { LightningElement,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';

export default class GenericAccordion extends LightningElement {

@api recordData;
questionsAnswers;

// connectedCallback(){
//         return refreshApex(this.recordData);
// }

        handleScoring(event){
            let scoreValue = event.detail.value;
            let currentId = event.currentTarget.dataset.id;
            this.fireCustomEvent(scoreValue,currentId);
        }

        fireCustomEvent(scoreValue,currentOppScoreId){
                const selectEvent = new CustomEvent('updaterecord',{
                         detail: {
                             scoreValue: scoreValue,
                             currentOppScoreId: currentOppScoreId
                         }
                });
                this.dispatchEvent(selectEvent);
        }
       
}