public class AccountDetailsHandler {

@AuraEnabled(cacheable=true)
public static List<Account> getChildAccounts(String recordIds){
        List<Account> accountList = [Select id,name,(Select id,name from ChildAccounts) 
                                     from Account where id =:recordIds];
        
        if(!accountList.isEmpty()){
            return accountList;
        }
        return null;
}
}