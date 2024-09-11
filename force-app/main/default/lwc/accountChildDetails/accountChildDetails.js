import { LightningElement,wire,api } from 'lwc';
import getChildAccounts from '@salesforce/apex/AccountDetailsHandler.getChildAccounts';
import { NavigationMixin } from 'lightning/navigation';
const columns = [
    { label: 'Name', type: 'button',fieldName: 'Name', typeAttributes: {
            label: { fieldName: 'Name' },
            name: 'Name',
            disabled: false,
            variant: 'base',
            value: 'Name',
            } },
    { label: 'Email', fieldName: 'Email'},
];

export default class AccountChildDetails extends NavigationMixin(LightningElement) {

    @api recordId;
    childAccountData=[];
    columns = columns;

    @wire(getChildAccounts,{recordIds : '$recordId'})
    wiredAccounts({ data,error}){
        if(data){
            console.log('data:'+JSON.stringify(data));
            console.log('data:'+JSON.stringify(data[0].ChildAccounts));
            this.childAccountData = data[0].ChildAccounts;
        }
        else if(error){
            console.log('error:'+JSON.stringify(error));
        }
    }

    handleRowAction(event) {
    if (event.detail.action.name ==  'Name') {
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: event.detail.row.Id, //console the id and put it here
          objectApiName: 'Account',
          actionName: 'view'
        }
      });
    }
 }
}