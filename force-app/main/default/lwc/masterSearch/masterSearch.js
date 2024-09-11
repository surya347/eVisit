import { LightningElement, api,wire } from 'lwc';
import getSearchData from '@salesforce/apex/MasterSearchHandler.getSearchData';
import { NavigationMixin } from 'lightning/navigation'; 
import USER_ID from '@salesforce/user/Id';
import Profile_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import Company_FIELD from '@salesforce/schema/Lead.Company';
import Name_FIELD from '@salesforce/schema/Lead';
import Parent_company_FIELD from '@salesforce/schema/Lead.Parent_Lead__c';
import Parent_company_Name_FIELD from '@salesforce/schema/Lead.Parent_Lead__r.Company';
import Ultimate_Parent_FIELD from '@salesforce/schema/Lead.Ultimate_Parent_Lead__c';
import { getRecord } from 'lightning/uiRecordApi';

export default class MasterSearch extends NavigationMixin(LightningElement) {

    @api searchKeyValue="";
    @api searchKeyType;
    @api searchForObject;
    autoCompleteOptions=[];
    isFocus=false;
    showContactDetails = false;
    isUserSystemAdmin = false;
    showParentModal = false;
    selectedItem;
    selectedCompany;
    fields = [Ultimate_Parent_FIELD,Parent_company_FIELD,Name_FIELD,Company_FIELD];
    isShowSpinner=false;

     @wire(getRecord, {
         recordId: USER_ID,
         fields: [Profile_NAME_FIELD]
     }) wireuser({
         error,
         data }) {
         if (error) {
            this.error = error ; 
         } else if (data) {
            let profileName = data.fields.Profile.displayValue;
            //  console.log('profileName:'+JSON.stringify(profileName));
            //  this.name = data.fields.Name.value;
            if(profileName == "System Administrator"){
                this.isUserSystemAdmin = true;
            }else{
                this.isUserSystemAdmin = false;
            }
         }
     }

    connectedCallback(){
        // console.log('searchKeyValue:'+JSON.stringify(this.searchKeyValue));
        // console.log('searchKeyType:'+JSON.stringify(this.searchKeyType));
        // console.log('searchForObject:'+JSON.stringify(this.searchForObject));
        // this.isSearchDataFound = true;
        if(this.searchForObject == "Lead"){
            this.showContactDetails = false;
        }else{
            this.showContactDetails = true;
        }
    }

    // handleFocus(){
    //     this.isFocus = true;
    // }


    handleSearch(event){
        this.searchKeyValue =event.target.value;
        if(this.searchKeyValue == ""){
            this.autoCompleteOptions =[];
        }
        // console.log('searchKeyValue>>:'+JSON.stringify(event.target.value));
    }

    handleOnLoad() {
        this.isShowSpinner = false;
        // console.log('handleOnLoad:'+JSON.stringify(event.detail));
      }


    searchRecords(){
        this.isShowSpinner = true;
    
        getSearchData({searchKey:this.searchKeyValue,searchField:this.searchKeyType,objectName:this.searchForObject})
        .then(result =>{
            this.isShowSpinner = false;
        //    console.log('result:'+JSON.stringify(result))
            this.autoCompleteOptions = result;
            if(result == null && this.searchKeyValue!=""){
                this.isFocus = true;

            }else{
                this.isFocus = false;
            }
            if(this.autoCompleteOptions.length>0){
                this.isFocus = false;
            }

        })
        .catch(error=>{
            this.isShowSpinner = false;
            console.log('error search:'+JSON.stringify(error))

        })
    }


    handleClickList(event){
        this.isShowSpinner = true;
        this.selectedItem = event.currentTarget.dataset.id;
        this.selectedCompany = event.currentTarget.dataset.name;
        // console.log('selectedItem>>:'+JSON.stringify(this.selectedItem));
        // console.log('selectedCompany>>:'+JSON.stringify(this.selectedCompany));
        if(this.searchForObject == "Lead"){
            if( this.selectedItem !=null){
                this.showParentModal = true;
            }
        }
        
    }

    handleNaviagteToRecord(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.selectedItem,
                objectApiName:"Lead",
                actionName: 'view'
            }
        });
    }

    hideModalBox(){
        this.showParentModal = false;
    }

    handleCreateNew(event){
        let selectedObject = event.currentTarget.dataset.id;
        //console.log('selectedObject>>:'+JSON.stringify(selectedObject));
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: selectedObject,
                actionName: 'new'
            }
        });

    }
}