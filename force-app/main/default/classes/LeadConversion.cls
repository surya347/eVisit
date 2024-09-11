public class LeadConversion{

	@AuraEnabled
    public static String getRecordDetails(String recordIds){
            Lead leadObj = [Select id,Name,Status from Lead Where Id =: recordIds];
            if(leadObj.Status != null){
                return leadObj.Status;
            }
            return null;
    }   
    
    @AuraEnabled
    public static String convertLeadToAccount(String leadRecordId,String leadName,
                                              String parentLeadRecordId,String parentLeadName,
                                              String ultimateParentLeadRecordId,String ultimateParentLeadName,
                                              List<String> parentUltimateContactIds,
                                              List<String> parentContactIds,List<String> contactIds){
      system.debug(leadRecordId+'-'+parentLeadRecordId+'-'+ultimateParentLeadRecordId);
      Lead leadDetail;
      String accountId;
      Lead parentLeadDetails;
      String parentAccountId;
      Lead ultimateParentLeadDetails;
      String ultimateParentAccountId;  
                                                  
      if(ultimateParentLeadRecordId !=null){
            ultimateParentLeadDetails = getLeadDetails(ultimateParentLeadRecordId);
            ultimateParentAccountId = convertToAccount(ultimateParentLeadName,ultimateParentLeadDetails,null); 
            system.debug('ultimateParentAccountId:'+ultimateParentAccountId);
              if(!parentUltimateContactIds.isEmpty()){
                 Boolean isContactLinked = linkContactsWithCreatedAccount(parentUltimateContactIds,ultimateParentAccountId);
              }
      }else{ // if ultimate parent lead is not present
                  
      }
                                                  
      if(parentLeadRecordId != null){
            parentLeadDetails = getLeadDetails(parentLeadRecordId);
            parentAccountId = convertToAccount(parentLeadName,parentLeadDetails,ultimateParentAccountId); 
          	system.debug('parentAccountId:'+parentAccountId);
          if(!parentContactIds.isEmpty()){
                 Boolean isContactLinked2 = linkContactsWithCreatedAccount(parentContactIds,parentAccountId);
              }
      }else{ // if parent lead is not present
              
      }  
                                                  
      if(leadRecordId !=null){
          leadDetail = getLeadDetails(leadRecordId);
          accountId =  convertToAccount(leadName,leadDetail,parentAccountId);
          system.debug('accountId:'+accountId);
          if(!contactIds.isEmpty()){
                 Boolean isContactLinked2 = linkContactsWithCreatedAccount(contactIds,accountId);
              }
          return 'Account Created';
       }
       return 'Failed';
                                                  
 }
    
    public static String convertToAccount(String accName,Lead leadData,String parentAccountId){

     try{
        String accountId='';
        List<Account> accList = [ Select id,name from Account];
        List<Account> accountListToUpsert = new List<Account>();
        
        for(Integer i=0;i<accList.size();i++){
            if(accList[i].Name == accName){
                system.debug(accList[i].Name +'-'+accName);	
                accountId = accList[i].Id;
            }
        }
        
        Account accObj = new Account();
        accObj.Name = accName;
        accObj.texcellency__DefHC_HospitalID__c = leadData.texcellency__DefHC_HospitalID__c;
        if(parentAccountId !=null){
          accObj.ParentId =  parentAccountId; 
        }
        accountListToUpsert.add(accObj);
        if(!accountListToUpsert.isEmpty()){
            system.debug('accountListToUpsert:'+accountListToUpsert);
            if(accountId ==null || accountId ==''){
                insert accountListToUpsert;
                accountId = accountListToUpsert[0].Id;
                system.debug('accountList after insert:'+accountListToUpsert[0].Id);
                return accountId;
            }else{
                return accountId;
            }  
        }
        return null;
        }
         catch(DmlException e) {
            System.debug(' failed: ' + e.getMessage());
            return null; 
        }
    }
    
    public static Lead getLeadDetails(String recordIds){
          Lead leadObj = [Select id,Name,Company,texcellency__DefHC_HospitalID__c,Status from Lead Where Id =: recordIds];
          return leadObj;
    }
        
    @AuraEnabled
    public static Boolean linkContactsWithCreatedAccount(List<String> contactIds, String accountId) {
        try {
            system.debug('contactIds:'+contactIds);
            system.debug('accountId:'+accountId);
            List<Contact> contactList = new List<Contact>();
            if(contactIds.size()>0){
                for(String conId : contactIds){
                    contact conObj = new contact();
                    conObj.AccountId = accountId;
                    conObj.Id = conId;
                    contactList.add(conObj);
                }
            }
            if(!contactList.isEmpty()){
                system.debug('contactList:'+contactList);
                update contactList;
                return true;
            }
            return false; 
        }
        catch(DmlException e) {
            System.debug('The contact update failed: ' + e.getMessage());
            return false; 
        }
    }
    
}