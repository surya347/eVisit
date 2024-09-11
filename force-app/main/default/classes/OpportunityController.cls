public class OpportunityController {
    
    public static void restrictSelectingPriorStage(Map<Id,Opportunity> oldOpportunityMap,List<Opportunity> newOpportunityList){
        system.debug('newOpportunityList:'+newOpportunityList);
        for( Opportunity opp : newOpportunityList){
            system.debug('value from map:'+oldOpportunityMap.get(opp.Id));
            //stageName change
            if(oldOpportunityMap != null && opp.StageName != oldOpportunityMap.get(opp.Id).StageName){
                if(opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost'){
                    if(opp.eVisit_Noted_Differentiators__c == null){
                        opp.eVisit_Noted_Differentiators__c.addError('Please select a value for eVisit Noted Differentiators');
                    }
                }  
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static  List<Object> getStageNames(String currentStage,String objectNames,String fieldNames){
        system.debug('currentStage:'+currentStage);
        
        List<Object> stageString = new List<Object>();
        String objectName = objectNames;
        String fieldName =fieldNames;
        
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            stageString.add(pickListVal.getLabel()+'='+pickListVal.getValue());
        }
        
        if(!stageString.isEmpty()){
            system.debug('stageStrings:'+stageString);
            return stageString;
        }
        return null;
        
       
    }
    
    @AuraEnabled
    public static String getRecordDetails(String recordIds){
        Opportunity oppObj = [Select id,Name,StageName from Opportunity Where Id =: recordIds];
        if(oppObj.StageName != null){
            return oppObj.StageName;
        }
        return null;
    }
    
}