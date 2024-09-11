@isTest
public class UploadLeadControllerTest {
    public static String str = 'Definitive ID,NETWORK_ID,NETWORK_PARENT_ID \n' +
        						'1,541814,7265';
    
    @testSetup static void testData(){
        List<Lead> leads = new List<Lead>{ new Lead(LastName='eVisit',Company='eVisit',texcellency__DefHC_HospitalID__c=1),
            							   new Lead(LastName='eVisit1',Company='eVisit1',texcellency__DefHC_HospitalID__c=541814),
            							   new Lead(LastName='eVisit2',Company='eVisit2',texcellency__DefHC_HospitalID__c=7265)};
            insert leads;
        
         ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.csv',
            VersionData = Blob.valueOf(str),
            IsMajorVersion = true
    		);
    	insert contentVersionInsert;
    }
    
    @isTest static void readCSVFileToUpdateParentLeadsTest(){
        Test.startTest();  
        List<Lead> conList = [Select id,Name,Company,texcellency__DefHC_HospitalID__c from Lead LIMIT 1];
        ContentVersion objVersion = [SELECT Id,ContentDocumentId FROM ContentVersion  LIMIT 1];
        List<Lead> l = UploadLeadController.readCSVFileToUpdateParentLeads(objVersion.ContentDocumentId);
        system.assertEquals(null,l);
        Test.stopTest();
        
    }
    
    /*@isTest static void readCSVFileToUpdateUltimateParentLeadsTest(){
        Test.startTest();  
        List<Lead> conList = [Select id,Name,Company,texcellency__DefHC_HospitalID__c from Lead LIMIT 1];
        ContentVersion objVersion = [SELECT Id,ContentDocumentId FROM ContentVersion  LIMIT 1];
        List<Lead> l = UploadLeadController.readCSVFileToUpdateUltimateParentLeads(objVersion.ContentDocumentId);
        system.assertEquals(null,l);
        Test.stopTest();
        
    }*/

}