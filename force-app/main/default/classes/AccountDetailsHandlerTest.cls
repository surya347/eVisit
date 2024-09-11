@isTest
public class AccountDetailsHandlerTest {
    
     @testSetup static void testData(){
        
        List<Account> accs = new List<Account>{ new Account(Name='eVisit')};
        insert accs;
    }
    
    @isTest static void getChildAccountsTest(){
        List<Account> accList = [Select id,Name from Account LIMIT 1];
        List<Account> acc = AccountDetailsHandler.getChildAccounts(accList[0].Id);
        system.assert(acc.size()>0);
    }

}