@isTest
public class LeadConversionTest {
    
      @testSetup static void testData(){
          
        List<Lead> ultimateparentLeads = new List<Lead>{ new Lead(LastName='eVisit ultimate parent',Company='eVisit ultimate parent',Status='New')};
        insert ultimateparentLeads;
          
        List<Lead> parentLeads = new List<Lead>{ new Lead(LastName='eVisit parent',Company='eVisit parent',Status='New')};
        insert parentLeads;
          
        List<Lead> leads = new List<Lead>{ new Lead(LastName='eVisit',Company='eVisit',Status='New',
                                                    Parent_Lead__c=parentLeads[0].Id,Ultimate_Parent_Lead__c=ultimateparentLeads[0].Id)};
        insert leads;
          
        List<Contact> cons = new List<Contact>{ new Contact(LastName='eVisit'),
            									new Contact(LastName='eVisits'),
            									new Contact(LastName='eVisitss')
            									};
        insert cons;
        
        List<Account> accs = new List<Account>{ new Account(Name='eVisit')};
        insert accs;
    }
    
     @isTest static void linkContactsWithCreatedAccount(){
        List<Contact> conList = [Select id,Name from Contact LIMIT 1];
        List<Account> accList = [Select id,Name from Account LIMIT 1];
        list<string> lst= new list<string>{conList[0].Id};
        Boolean bool = LeadConversion.linkContactsWithCreatedAccount(lst,accList[0].Id);
        system.assertEquals(true,bool);
    }
    
    @isTest static void linkContactsWithCreatedAccountFalse(){
        List<Contact> conList = [Select id,Name from Contact LIMIT 1];
        List<Account> accList = [Select id,Name from Account LIMIT 1];
        list<string> lst= new list<string>{conList[0].Id};
            delete conList;
        Boolean bool = LeadConversion.linkContactsWithCreatedAccount(lst,accList[0].Id);
        system.assertEquals(false,bool);
    }
    
    @isTest static void convertAccount(){
        List<Contact> conList = [Select id,Name from Contact];
        List<Account> accList = [Select id,Name from Account LIMIT 1];
        List<Lead> leadList = [Select id,name,Company,Parent_Lead__c,Parent_Lead__r.Name,Ultimate_Parent_Lead__c,Ultimate_Parent_Lead__r.Name
                               from Lead where Company='eVisit' ];
        list<string> lst1= new list<string>{conList[0].Id};
        list<string> lst2= new list<string>{conList[1].Id};
        list<string> lst3= new list<string>{conList[2].Id};
        String s = accList[0].Id;
       
        String response = LeadConversion.convertLeadToAccount(leadList[0].Id,leadList[0].name,leadList[0].Parent_Lead__c,leadList[0].Parent_Lead__r.Name,
                                                           leadList[0].Ultimate_Parent_Lead__c,leadList[0].Ultimate_Parent_Lead__r.Name
                                                           ,lst1,lst2,lst3);
        system.assertEquals('Account Created',response);
    }
    
    @isTest static void convertAccountfail(){
        List<Contact> conList = [Select id,Name from Contact];
         List<Contact> conLists = [Select id,Name from Contact LIMIT 1];
         List<Lead> leadList = [Select id,name,Company,Parent_Lead__c,Parent_Lead__r.Name,Ultimate_Parent_Lead__c,Ultimate_Parent_Lead__r.Name
                               from Lead where Company='eVisit' ];
         list<string> lst1= new list<string>{conList[0].Id};
        list<string> lst2= new list<string>{conList[1].Id};
        list<string> lst3= new list<string>{conList[2].Id};
       
        String bool = LeadConversion.convertLeadToAccount(null,leadList[0].name,leadList[0].Parent_Lead__c,leadList[0].Parent_Lead__r.Name,
                                                           leadList[0].Ultimate_Parent_Lead__c,leadList[0].Ultimate_Parent_Lead__r.Name
                                                           ,lst1,lst2,lst3);
        system.assertEquals('Failed',bool);
    }
    
    @isTest static void getRecordDetailsTest(){
        List<Lead> newLeadLIst = [Select id,Name,Status from Lead LIMIT 1];
        String s = LeadConversion.getRecordDetails(newLeadLIst[0].Id);
        System.assertEquals(s,'New');
    }


}