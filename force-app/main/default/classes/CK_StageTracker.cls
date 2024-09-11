/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):CK_StageTrackerTest
Description:Object agnostic class to use on triggers.
            This code checks when to create a new stage tracker or when to
            update an exsiting one. 

            Note: Only works for Leads,Opportunties and Cases

History:
 Date:2018-05-18
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
public without sharing class CK_StageTracker implements CK_TriggerHandler.HandlerInterface {

    private Schema.SObjectType schema;

    private static Map<Schema.SObjectType,String> acceptedSchema;
    private static Map<String,CK_Stage_Tracker_Settings__mdt> trackerSettings;
    private static String nameSpacePrefix;

    public void handle(){

        setupAcceptedSchema();
        if(Trigger.isDelete){
            // Trigger is delete, NewMap doesn't exist in this context
            deleteObject(trigger.oldMap);
        } else if(Trigger.isInsert){
            // Trigger is insert, OldMap doesn't exist in this context
            insertObject(trigger.newMap);
        } else if(Trigger.isUpdate){
            // Trigger is update all Maps exist in this context
            updateObject(Trigger.newMap,Trigger.oldMap);
        } else if(Trigger.isUndelete){
            // Trigger is Undelete, newMap Doesn't exist in this context
            // TODO: Double check above
            unDeleteObject(Trigger.newMap);
        }
    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-18
    Description:When an object is deleted all the StageTracking
        assoicated to those objects need to be deleted as well
    
    Inputs:Trigger OldMap, map of all objects deleted
    Outputs:None
    *****************************************************************/
    private void deleteObject(Map<Id,SObject> oldMap){
        schema = oldmap.getSObjectType();
        checkAcceptedSchema('Delete');
        Set<Id> deletedIds = oldMap.keySet();
        String lookupField = getTrackerLookupField();

        // Delete all assoicated Stage trackers
        StageTracker__c[] oldTrackers;
        String deleteQuery = 'Select id from StageTracker__c where ' + lookupField + ' in: deletedIds';

        try{
            oldTrackers = Database.query(deleteQuery);
        } catch(Exception e){
            System.Debug('Failed to query records to delete');
            throw new FailedQueryException('Failed to query stagetrackers related to the object ' + schema + ' being deleted');
        }
        if(!oldTrackers.isEmpty()){
            Database.DeleteResult[] deleteRes = Database.delete(oldTrackers, false);
        }

    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-18
    Description:When an object is update see if the stage/status has
        changed if so create/update stage tracker appropriately

    
    Inputs:Trigger new map of objects changed
            Trigger old map of objects values before they changed
    Outputs:None
    *****************************************************************/
    private void updateObject(Map<Id,SObject> newMap, Map<Id,SObject> oldMap){
        schema = newMap.getSObjectType();
        Recordtype recType = checkAcceptedSchema('Update');
        String lookupField = getTrackerLookupField();
        String stageFieldName = acceptedSchema.get(schema);
        Set<Id> changedIds = new Set<Id>();
        StageTracker__c[] updatedTrackers = new StageTracker__c[]{};
        StageTracker__c[] newTrackers = new StageTracker__c[]{};

        // Check for stage/status changes
        for(Sobject obj : newMap.values()){
            if(obj.get(stageFieldName) != oldMap.get(obj.Id).get(stageFieldName)){
                // Field has changed
                changedIds.add(obj.id);
            }
        }

        // Get related trackers for old stages
        String relatedTrackerQueryString = 'Select id,' + lookupField+ ',name,Inactive_Date__c,Last_Active_Date__c,Times_Moved_To__c,Times_Moved_Out__c from StageTracker__c where ' + lookupField +' in: changedIds';
        StageTracker__c[] relatedTrackers;
        try{
            relatedTrackers = Database.query(relatedTrackerQueryString);
        } catch(Exception e){
            System.Debug('Failed to query related Trackers');
            throw new FailedQueryException('Failed to query related stagetrackers during the update for ' + schema + 's');
        }

        // Check movement in/out of tracker
        for(StageTracker__c tracker : relatedTrackers){
            String relatedObjId = String.valueOf(tracker.get(lookupField));
            // Find tracker by stagefield name
            if(newMap.get(relatedObjId).get(stageFieldName) == tracker.name){

                // Moving back into this tracker record
                Date inactiveDate = Date.valueOf(tracker.Inactive_Date__c);
                Date activateDate = Date.valueOf(tracker.Last_Active_Date__c); // Required Field
                Decimal daysBetween = 0;
                if(inactiveDate == null ){
                    System.Debug('Inactive Date is not populated, assuming this record should not be updated');
                    continue;
                } else if(activateDate == null){
                    System.Debug('Activate Date is not populated');
                } else {
                    daysBetween = activateDate.daysBetween(inactiveDate);
                }

                tracker.Times_Moved_To__c++;
                tracker.Cumulated_Days__c = tracker.Cumulated_Days__c == null ? daysBetween : tracker.Cumulated_Days__c + daysBetween;
                tracker.Inactive_Date__c = null;
                tracker.Last_Active_Date__c = DateTime.now();
                updatedTrackers.add(tracker);
                
                // remove id from changedIds to later use this set to create new
                // stage trackers
                changedIds.remove(relatedObjId);
            } else if(oldMap.get(relatedObjId).get(stageFieldName) == tracker.name){

                // Moving out of this tracker record
                tracker.Times_Moved_Out__c++;
                tracker.Inactive_Date__c = DateTime.Now();
                updatedTrackers.add(tracker);
            }
        }

        // Create new trackers as needed
        for(Id objId : changedIds){
            StageTracker__c tracker = new StageTracker__c(
                Last_Active_Date__c = DateTime.now(),
                Name = String.valueOf(newMap.get(objId).get(stageFieldName)),
                RecordtypeId = recType.Id,
                Cumulated_Days__c = 0,
                Times_Moved_To__c = 1,
                Times_Moved_Out__c = 0
            );
            tracker.put(lookupField,objId);
            newTrackers.add(tracker);
        }            

        if(!updatedTrackers.isEmpty()){
            Database.SaveResult[] updatedResults = Database.update(updatedTrackers,false);
        }
        if(!newTrackers.isEmpty()){
            Database.SaveResult[] insertResults = Database.insert(newTrackers,false);
        }

    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-18
    Description:When an object is inserted create the stage tracker
                for the current stage/status
    
    Inputs:Trigger new map of objects created
    Outputs:None
    *****************************************************************/
    private void insertObject(Map<Id,SObject> newMap){
        schema = newMap.getSObjectType();
        Recordtype recType = checkAcceptedSchema('Insert');
        StageTracker__c[] newTrackerList = new StageTracker__c[]{};
        String lookupField = getTrackerLookupField();
        
        for(SObject obj: newMap.values()){
            StageTracker__c tracker = new StageTracker__c(
                Last_Active_Date__c = DateTime.now(),
                Name = String.valueOf(obj.get(acceptedSchema.get(schema))),
                RecordtypeId = recType.Id,
                Cumulated_Days__c = 0,
                Times_Moved_To__c = 1,
                Times_Moved_Out__c = 0
            );
            tracker.put(lookupField, obj.Id);
            newTrackerList.add(tracker);
        }

        Database.SaveResult[] saveRes = Database.insert(newTrackerList,false);
    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-18
    Description:When an object is undeleted all the stage tracker 
                records for that object also need to be un deleted
    
    Inputs:Tigger oldmap of objects being undeleted
    Outputs:None
    *****************************************************************/
    private void unDeleteObject(Map<Id,SObject> newMap){
        schema = newMap.getSObjectType();
        checkAcceptedSchema('Undelete');
        String lookupField = getTrackerLookupField();
        Set<Id> undeletedIds = newMap.keySet();


        StageTracker__c[] undeletedTrackers;
        String trackerQuery = 'Select id from StageTracker__C where ' + lookupField + ' in:undeletedIds and isdeleted = true ALL ROWS';
        try{
            undeletedTrackers = Database.query(trackerQuery);
        } catch(Exception e){
            System.Debug('Failed to query for undeleted trackers');
            System.Debug(e);
            throw new FailedQueryException('Failed to get related undeleted StageTrackers while undeleteing ' + schema);
        }

        if(!undeletedTrackers.isEmpty()){
            Database.UndeleteResult[] undeleteRes = Database.undelete(undeletedTrackers,false);
        }

    }


    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-29
    Description:Checks to ensure if the schema aligns correctly by 
    ensuring the object being triggered is supported by stage tracker
    
    Makes sure the recordtype exsits for this object and returns that
    recordtype in the same call
    
    Inputs:String to help debug where the method came from
    Outputs:Recordtype for Stagetracker related to the appropriate 
    schema
    *****************************************************************/
    private RecordType checkAcceptedSchema(String methodName){

        if(!acceptedSchema.containsKey(schema))
            throw new IncorrectSchemaException(methodName + ' Method for CK_StageTracker does not support the object:' + schema);

        // Check to make sure field exists for accepted schema
        // field name is custom so need to make sure schema has a __c
        String fieldName = getTrackerLookupField();
        String fieldNameWNS = getNameSpacePrefix() + fieldName;
        
        if(!StageTracker__C.SObjectType.getDescribe().fields.getMap().containsKey(fieldNameWNS)){
            throw new IncorrectSchemaException('StageTracker does not have a field named ' + fieldNameWNS );
        }

        // Recordtype dev names don't have __c
        String recordTypeName = fieldName;
        recordTypeName = recordTypeName.replace('__c','');
        String trackerObjName = getNameSpacePrefix() + 'StageTracker__c';

        RecordType[] recTypes = [Select Id,sObjectType from RecordType where DeveloperName =: recordTypeName];
        RecordType stageTrackerRecordType;
        
        // Workaround for not being able to query sObjectType with a namespace included in the text while packaging
        for(RecordType rec : recTypes){
            if(rec.sObjectType == trackerObjName){
                stageTrackerRecordType = rec;
                break;
            }
        }


        if(stageTrackerRecordType == null){
            throw new IncorrectSchemaException('Stagetracker does not have a recordtype named ' + recordTypeName);
        }

        return stageTrackerRecordType;
    }
    
    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-29
    Description:Get the name of the lookup field related to the 
    object on the Stage Tracker object
    
    Inputs:None
    Outputs:Name of the StageTracker lookup field appened with __c
    *****************************************************************/
    private String getTrackerLookupField(){
        String fieldName = String.valueOf(schema);
        if(!fieldName.contains('__c')){
            fieldName += '__c';
        }

        return fieldName;
    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-30
    Description:Setup the Accepted Schema mapping which is used to 
    know which field to track for each object
    
    Inputs:None
    Outputs:None
    *****************************************************************/
    private static void setupAcceptedSchema(){
        trackerSettings = getTrackerSettings();
        acceptedSchema = new Map<Schema.SobjectType,String>();
        for(String objName : trackerSettings.keySet()){
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objName);
            acceptedSchema.put(objectType, trackerSettings.get(objName).Stage_Status_Api_Name__c);
        }
    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-31
    Description:Get the Namespace for this component, needed for 
    dynamic references to fields
    
    Inputs:none
    Outputs:String value of Namespace prefix
    *****************************************************************/
    private String getNameSpacePrefix(){
        if(nameSpacePrefix == null){
            String[] splitString = CK_StageTracker.class.getName().split('\\.');
            if(splitString.size() <= 1){
                nameSpacePrefix = '';
            } else {
                nameSpacePrefix = splitString[0] + '__';
            }
        }
        System.Debug(nameSpacePrefix);
        return nameSpacePrefix;
    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-30
    Description:Get method for the custom metadata which stores the
    settings for the application
    
    Inputs:None
    Outputs:Map of Object names to Stage Tracker Settings MDT 
    *****************************************************************/
    public static Map<String,CK_Stage_Tracker_Settings__mdt> getTrackerSettings(){
        if(trackerSettings != null){
            return trackerSettings;
        } else {
            trackerSettings = new Map<String,CK_Stage_Tracker_Settings__mdt>();
            CK_Stage_Tracker_Settings__mdt[] trackerSettingsList = [SELECT id, label,Stage_Status_Api_Name__c,Sync_Deletes_Undeletes__c,Track_Changes__c FROM CK_Stage_Tracker_Settings__mdt];
            for(CK_Stage_Tracker_Settings__mdt settings: trackerSettingsList){
                trackerSettings.put(settings.label,settings);
            }
        }
        return trackerSettings;
    }


    // Custom Errors
    public class IncorrectSchemaException extends Exception {}
    public class FailedQueryException extends Exception {}

}