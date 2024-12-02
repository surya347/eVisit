import { LightningElement,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';

export default class GenericAccordion extends LightningElement {

@api recordData;
questionsAnswers;
notes='';
scoreValue='';
buttonLabel='Edit';
recordsToUpdate=[];
timer;

        handleNotes(event){
            this.notes = event.target.value;
            console.log('this.notes:',JSON.stringify( this.notes));
        }

        handleSaveNote(event){
            this.scoreValue='';
            let currentId = event.currentTarget.dataset.id;
            if(event.target.label =='Edit'){
                this.template.querySelector(`[data-name="${currentId}"]`).disabled = false;
                this.template.querySelector(`[data-btn="${currentId}"]`).label = 'Update';
            }else{
                this.fireCustomEvent(this.scoreValue,this.notes,currentId);
                this.template.querySelector(`[data-name="${currentId}"]`).disabled = true;
                this.template.querySelector(`[data-btn="${currentId}"]`).label = 'Edit';
            }
            
        }

        handleScoring(event){
            window.clearTimeout(this.timer)
            this.notes='';
            this.scoreValue = event.detail.value;
            let currentId = event.currentTarget.dataset.id;
            this.timer = setTimeout(()=>{
                this.fireCustomEvent(this.scoreValue,this.notes,currentId);
            }, 1000)
        }

        fireCustomEvent(scoreValue,notesValue,currentOppScoreId){
                const selectEvent = new CustomEvent('updaterecord',{
                         detail: {
                             scoreValue: scoreValue,
                             notesValue: notesValue,
                             currentOppScoreId: currentOppScoreId
                         }
                });
                this.dispatchEvent(selectEvent);
        }
       
}