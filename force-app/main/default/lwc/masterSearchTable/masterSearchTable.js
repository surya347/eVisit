import { LightningElement } from 'lwc';
import getAllData from '@salesforce/apex/MasterSearchHandler.getAllData';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email'},
];

export default class MasterSearchTable extends LightningElement {

    recordData;
    columns = columns;
    searchForObject="Lead";

   connectedCallback(){
   this.getRecordsDetail(this.searchForObject);
   }

   handleActive(event){
    this.searchForObject = event.target.value;
    this.getRecordsDetail(this.searchForObject);

   }
   getRecordsDetail(searchForObject){
    getAllData({objectName:searchForObject})
    .then(result =>{
        //console.log('result:'+JSON.stringify(result))
        this.recordData = result;

    })
    .catch(error=>{
        console.log('error all data:'+JSON.stringify(error))

    })
   }

   
}