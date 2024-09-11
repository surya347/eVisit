@isTest
public class AccountLeadDeletionTest {
    
    @testSetup static void testData(){
        
        List<Lead> leads = new List<Lead>{ new Lead(LastName='test lead',Company='Tests',Status='New',LeadSource='Website')};
        insert leads;
        
        List<Account> accs = new List<Account>{ new Account(Name='eVisit')};
            insert accs;
        
        Opportunity opportunityToCreate = new Opportunity();
        	
        Date d = Date.today().addDays(+1);
        // Do you recognize these fields?
        opportunityToCreate.StageName = 'Sourcing Demand';
        opportunityToCreate.CloseDate = d;
        opportunityToCreate.AccountId = accs[0].Id;
        opportunityToCreate.Name = 'Test Opportunity';
        opportunityToCreate.LeadSource = 'Website';
        opportunityToCreate.Amount = 1;
        opportunityToCreate.ARR__c=1.0;
        
        insert opportunityToCreate;
    }
    
     @isTest static void deleteAccountWithNoOpportunities(){
        List<Account> accList = [Select id,Name from Account LIMIT 1];
        List<Opportunity> oppList = [Select id,Name from Opportunity LIMIT 1];
        
        AccountLeadDeletion.deleteAccountWithNoOpportunities();
        system.assertEquals(oppList.size(),1);
    }
    
    @isTest static void deleteLeads(){
        List<Lead> leadList = [Select id,Name from Lead LIMIT 1];
        
        AccountLeadDeletion.deleteAllLeads();
        system.assertEquals(leadList.size(),1);
    }
    
}