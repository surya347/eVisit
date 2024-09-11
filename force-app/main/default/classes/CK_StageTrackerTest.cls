/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Description:Test class for the Stage Tracker managment functionaility

History:
 Date:2018-05-29
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
@isTest
private class CK_StageTrackerTest {

	@TestSetup
	static void setupMethod(){
		// Create 10 test leads
		Lead[] testLeads = CK_TestFactory.createLeads(10);
		Database.SaveResult[] leadRes = Database.insert(testLeads,false);
		for(Database.SaveResult res : leadRes){
			System.assert(res.isSuccess());
		}

		// Create 1 account
		Account[] testAccount = CK_TestFactory.createAccounts(1);
		Database.SaveResult[] accountRes = Database.insert(testAccount,false);
		for(Database.SaveResult res : accountRes){
			System.assert(res.isSuccess());
		}

		// Create 10 Opps
		Opportunity[] testOpps = CK_TestFactory.createOpportunities(10,accountRes[0].getId());
		Database.SaveResult[] oppRes = Database.insert(testOpps,false);
		for(Database.SaveResult res : oppRes){
			System.assert(res.isSuccess());
		}

		// Create 10 Cases
		Case[] testCases = CK_TestFactory.createCases(10,accountRes[0].getId());
		Database.SaveResult[] caseRes = Database.insert(testCases, false);
		for(Database.SaveResult res : caseRes){
			System.assert(res.isSuccess());
		}
	}

	@isTest static void LeadUpdate() {
		Map<Id,Lead> testLeads = new Map<Id,Lead>([Select id,status from Lead]);
		Map<Id,StageTracker__c> leadTrackers = new Map<Id,StageTracker__c> ([Select id FROM StageTracker__c Where lead__c in: testLeads.keySet()]);

		Integer startingTrackerSize = leadTrackers.size();
		String startingStatus = testLeads.values()[0].status;

		System.assertEquals(testleads.size(), startingTrackerSize);

		Test.startTest();

		// Change status to a random new one
		for(Lead oLead : testLeads.values()){
			oLead.status = Ck_TestFactory.getRandomPicklistValue(Lead.sObjectType, 'Status', oLead.status);
			testLeads.put(oLead.id,oLead);
		}

		Database.SaveResult[] leadUpdate = Database.update(testLeads.values(),false);
		for(Database.SaveResult res : leadUpdate){
			System.assert(res.isSuccess());
		}

		leadTrackers = new Map<Id,StageTracker__c>([Select id ,name,Last_Active_date__c, Inactive_Date__c ,Times_Moved_Out__c, Times_Moved_To__c,Lead__c FROM StageTracker__c WHERE lead__c in: testleads.keySet()]);
		System.assertNotEquals(startingTrackerSize, leadTrackers.size());

		for(StageTracker__c tracker : leadTrackers.values()){
			Lead relatedLead = testLeads.get(tracker.lead__c);
			if(relatedLead.status != tracker.name){
				// Tracker for state 0
				System.assert(tracker.Times_Moved_Out__c > 0);
				System.assert(tracker.Inactive_Date__c != null);
				tracker.Last_Active_date__c = DateTime.now().addDays(-1);
				leadTrackers.put(tracker.id,tracker);
			} else {
				// Tracker for new state
				System.assert(tracker.Times_Moved_Out__c == 0);
				System.assert(tracker.Inactive_Date__c == null);
			}
		}

		// Update dates on trackers
		Database.SaveResult[] trackerRes = Database.update(leadTrackers.values(),false);
		for(Database.SaveResult res: trackerRes){
			System.assert(res.isSuccess());
		}

		// Change status back to the old one
		for(Lead oLead : testLeads.values()){
			oLead.status = startingStatus;
			testLeads.put(oLead.id,oLead);
		}
		Database.SaveResult[] leadUpdate2 = Database.update(testLeads.values(),false);
		for(Database.SaveResult res : leadUpdate2){
			System.assert(res.isSuccess());
		}

		leadTrackers = new Map<Id,StageTracker__c>([Select id,Cumulated_Days__c,Inactive_Date__c ,Times_Moved_Out__c, Times_Moved_To__c,Lead__c FROM StageTracker__c WHERE lead__c in: testleads.keySet() AND name =: startingStatus]);
		System.assertEquals(startingTrackerSize,leadTrackers.size());
		for(StageTracker__c tracker : leadTrackers.values()){
			System.assert(tracker.Times_Moved_To__c == 2);
			System.assert(tracker.Inactive_Date__c == null);
			System.assertEquals(tracker.Cumulated_Days__c, 1);
		}

		Test.stopTest();
		
	}
	
	@isTest static void leadDeleteAndUndelete() {
		Map<Id,Lead> testLeads = new Map<Id,Lead>([Select id FROM Lead]);
		Integer countOfTrackers = [Select count() from StageTracker__c where lead__c in: testLeads.keySet()];

		Database.DeleteResult[] leadDelRes = Database.delete(testLeads.values(),false);
		for(Database.DeleteResult res : leadDelRes){
			System.assert(res.isSuccess());
		}

		Integer deletedCount = [Select count() from StageTracker__c where lead__c in: testLeads.keySet()];

		System.assertNotEquals(countOfTrackers,deletedCount);

		// Undelete
		Database.UndeleteResult[] leadUndelRes = Database.undelete(testLeads.values());
		for(Database.UndeleteResult res : leadUndelRes){
			System.assert(res.isSuccess());
		}

		Integer undeletedCount = [Select count() from StageTracker__c where Lead__c in: testLeads.keySet()];

		System.assertEquals(countOfTrackers,undeletedCount);
	}


}