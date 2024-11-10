@isTest
public class OpportunityControllerTest {
    
      @testSetup static void testData(){
          
        Date dt = Date.today().addDays(+1);
          
        Account accs = new Account(Name='Test Account');
    	insert accs;
          
        Opportunity opps = new Opportunity(Name='Test',Amount=12,stageName='Discovery and Qualification',AccountId=accs.Id,LeadSource='Website',ARR__c=10,Use_Case__c='Primary Care',CloseDate=dt,Implementation_Fee__c=10);
        insert opps;
          
        Opportunity opps1 = new Opportunity(Name='Test1',Amount=12,stageName='Closed Won',AccountId=accs.Id,LeadSource='Website',ARR__c=10,Use_Case__c='Primary Care',CloseDate=dt,Implementation_Fee__c=10);
        insert opps1;
        
    }
    
     @isTest static void OpportunityControllerTrigger(){
        List<Account> accList = [Select id,Name from Account LIMIT 1];
        List<Opportunity> newoppLIst = [Select id,Name,Amount,stageName,AccountId,LeadSource,ARR__c,Use_Case__c,Implementation_Fee__c from Opportunity Where Name = 'Test'];
        newoppLIst[0].stageName = 'Closed Lost';
        newoppLIst[0].Loss_Reason__c = 'Competitor';
         
        Test.startTest();
        List<Database.SaveResult> result = Database.update(newoppLIst, false);
        Test.stopTest();
           /* System.assert(!result[0].isSuccess());
            System.assert(result[0].getErrors().size() > 0);
            System.assertEquals('Please select a value for eVisit Noted Differentiators',result[0].getErrors()[0].getMessage());
			*/
    }
    
    @isTest static void getStageNamesTest(){
        List<Opportunity> newoppLIst = [Select id,Name,Amount,stageName,AccountId,LeadSource,ARR__c,Implementation_Fee__c,Use_Case__c from Opportunity Where Name = 'Test'];
        List<Object> stageString = new List<Object>();
         stageString.add(newoppLIst[0].stageName+'='+newoppLIst[0].stageName);
         List<Object> oppObj = OpportunityController.getStageNames('Closed Won','Opportunity','StageName');
       	 System.assert(oppObj.size() > 0);
    }
    
    @isTest static void getRecordDetailsTest(){
        List<Opportunity> newoppLIst = [Select id,Name,Amount,stageName,AccountId,LeadSource,ARR__c,Implementation_Fee__c,Use_Case__c from Opportunity Where Name = 'Test'];
        String s = OpportunityController.getRecordDetails(newoppLIst[0].Id);
        System.assertEquals(s,'Discovery and Qualification');
    }

}