/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):CK_StageTrackerTest
Description:Trigger to handle all Lead Events

History:
 Date:2018-05-18
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
trigger CK_LeadTrigger on Lead (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		Ck_triggerHandler handler = new Ck_triggerHandler();
		CK_StageTracker tracker = new CK_StageTracker();

		Map<String,CK_Stage_Tracker_Settings__mdt> settings = CK_StageTracker.getTrackerSettings();
		if(settings.containsKey(String.valueOf(Lead.SobjectType))){
			if(settings.get(String.valueOf(Lead.SobjectType)).Track_Changes__c){
				handler.bind(Ck_triggerHandler.Evt.afterinsert, tracker); // Insert
				handler.bind(Ck_triggerHandler.Evt.afterupdate, tracker); // Update
			}
			if(settings.get(String.valueOf(Lead.SobjectType)).Sync_Deletes_Undeletes__c){
				handler.bind(Ck_triggerHandler.Evt.afterdelete, tracker); // Delete
				handler.bind(Ck_triggerHandler.Evt.afterundelete, tracker); // Undelete
			}
			handler.manage();
		}
		
}