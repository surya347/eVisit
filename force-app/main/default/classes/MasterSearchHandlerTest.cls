@isTest
public class MasterSearchHandlerTest {
    
    @testSetup static void testData(){
        List<Lead> leads = new List<Lead>{ new Lead(LastName='eVisit',Company='eVisit')};
            insert leads;
        
        List<Contact> cons = new List<Contact>{ new Contact(LastName='eVisit')};
        insert cons;
        
        List<Account> accs = new List<Account>{ new Account(Name='eVisit')};
        insert accs;
    }
    
    @isTest static void getSearchData(){
        
        List<sObject> sObjectList = MasterSearchHandler.getSearchData('eVisit','Company','Lead');
        system.assertEquals(1,sObjectList.size());
    }
    
    @isTest static void getSearchDataNull(){
        List<sObject> sObjectList = MasterSearchHandler.getSearchData('eVisits','Company','Lead');
        system.assertEquals(null,sObjectList);
    }
    
     @isTest static void getSearchDataEmptyName(){
        List<Lead> lists =[Select Id,name from Lead];
        delete lists;
        List<sObject> sObjectList = MasterSearchHandler.getSearchData('','Company','Lead');
        system.assertEquals(null,sObjectList);
    }
    
    @isTest static void getAllData(){
        List<sObject> sObjectList = MasterSearchHandler.getAllData('Lead');
        system.assertEquals(1,sObjectList.size());
    }
    
    @isTest static void getAllDataNull(){
        List<Lead> lists =[Select Id,name from Lead];
        delete lists;
        List<sObject> sObjectList = MasterSearchHandler.getAllData('Lead');
        system.assertEquals(null,sObjectList);
    }
    
}