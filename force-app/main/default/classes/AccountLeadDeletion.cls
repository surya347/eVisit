public class AccountLeadDeletion {
    
    public static void deleteAccountWithNoOpportunities(){
        List<Account> accountListTodelete = new List<Account>();
        List<Opportunity> oppList = [select id,name,AccountId from Opportunity Where AccountId !=null];
        System.debug('oppList:'+oppList);
        
        Set<Id> accountIdSet = new Set<Id>();
        
        for(Opportunity opp : oppList){
            accountIdSet.add(opp.AccountId);
        }
        
        system.debug('accountIdSet:'+accountIdSet);
        
        if(accountIdSet.size()>0){
            // Query the accounts to delete
            accountListTodelete = [Select Id,Name from Account where Id NOT IN: accountIdSet];
            system.debug('accountListTodelete:'+accountListTodelete);            
        }
        
        if(!accountListTodelete.isEmpty()){
            
            // Delete the accounts
            Database.DeleteResult[] drList = Database.delete(accountListTodelete, false);
            
            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted account with ID: ' + dr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
    }
    
    public static void deleteAllLeads(){
        List<Lead> leadListTodelete = [Select Id,Name from Lead LIMIT 100];
        
        if(!leadListTodelete.isEmpty()){
            system.debug('leadListTodelete:'+leadListTodelete);
            delete leadListTodelete;
        }
    }
    
}