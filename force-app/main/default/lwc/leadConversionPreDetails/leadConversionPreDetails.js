import { LightningElement,api } from 'lwc';
// import MyModal from 'c/myModal';

const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email'},
];

export default class LeadConversionPreDetails extends LightningElement {

    columns = columns;
    @api content='test';
    @api acountName;
    @api parentAccountName;
    @api ultimateParentAccountName;
    @api relatedContacts;
    relatedContactsId=[];
    relatedParentContactsId=[];
    relatedUltimateParentContactsId=[];
    contactDataForDatatable=[];
    @api isShowSpinner = false;
    showParentAccount=false;
    showUltimateParentAccount=false;
    @api relatedParentContacts;
    @api relatedUltimateParentContacts
    isShowContactInDatatable=false;

    connectedCallback(){
        // console.log('this.relatedContacts:'+JSON.stringify(this.relatedContacts));
        // console.log('this.relatedParentContacts:'+JSON.stringify(this.relatedParentContacts));

        if(this.parentAccountName !=null || this.parentAccountName !=undefined){
            this.showParentAccount = true;
        }else{
            this.showParentAccount = false;
        }

        if(this.ultimateParentAccountName !=null || this.ultimateParentAccountName !=undefined){
            this.showUltimateParentAccount = true;
        }else{
            this.showUltimateParentAccount = false;
        }

        //organizing contact data
        if(this.relatedContacts !=undefined){
        if(this.relatedContacts.length>0){
            // console.log('relatedContacts:'+JSON.stringify(this.relatedContacts));
            let arr =[];
            let arrForId =[];
            this.relatedContacts.forEach((element)=>{
                let id = element.fields.Id.value;
                let name = element.fields.Name.value;
                let email = element.fields.Email.value;
                arr.push({"Id":id,"Name":name,"Email":email});
                arrForId.push(id);
            })

            if(arr.length>0){
                this.contactDataForDatatable = arr;
                if(this.contactDataForDatatable.length>0){
                    this.isShowContactInDatatable=true;
                }else{
                    this.isShowContactInDatatable=false;
                }
                this.relatedContactsId = arrForId;
                //  console.log('contactDataForDatatable:'+JSON.stringify(this.contactDataForDatatable));
            }
        }
        }

        if(this.relatedParentContacts !=undefined){
        //organizing parent contact data
            if(this.relatedParentContacts.length>0){
                // console.log('relatedParentContacts:'+JSON.stringify(this.relatedParentContacts));
                let arrForId =[];
                this.relatedParentContacts.forEach((element)=>{
                    let id = element.fields.Id.value;
                    arrForId.push(id);
                })

                if(arrForId.length>0){
                    this.relatedParentContactsId = arrForId;
                    // console.log('relatedParentContactsId:'+JSON.stringify(this.relatedParentContactsId));
                }
            }
        }

        if(this.relatedUltimateParentContacts !=undefined){
            //organizing parent contact data
                if(this.relatedUltimateParentContacts.length>0){
                    // console.log('relatedUltimateParentContacts:'+JSON.stringify(this.relatedUltimateParentContacts));
                    let arrForId =[];
                    this.relatedUltimateParentContacts.forEach((element)=>{
                        let id = element.fields.Id.value;
                        arrForId.push(id);
                    })
    
                    if(arrForId.length>0){
                        this.relatedUltimateParentContactsId = arrForId;
                        // console.log('relatedUltimateParentContactsId:'+JSON.stringify(this.relatedUltimateParentContactsId));
                    }
                }
            }
    }



    handleOkay() {
        this.close('okay');
    }

    hideModalBox(){
        this.dispatchEvent(new CustomEvent("close"));
    }

    handleSectionToggle(event){
        event.preventDefault();
        // console.log('Open section name:  ' + JSON.stringify(event.detail.openSections));
         this.activeSection = event.detail.openSections;
    }

    handleLeadConversion(){
        this.isShowSpinner=true;
        this.dispatchEvent(new CustomEvent("save",{
            detail:{
              contactIds: this.relatedContactsId,
              parentContactIds:this.relatedParentContactsId,
              ultimateParentContactsId:this.relatedUltimateParentContactsId
            }
        }));
    }
}