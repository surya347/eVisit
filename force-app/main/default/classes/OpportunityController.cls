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
                    if(opp.StageName == 'Closed Lost' && opp.Loss_Reason__c ==null){
                        opp.Loss_Reason__c.addError('Please select a value for Loss Reason');
                    }
                }  
            }
            
            //updating Amount field
            if(opp.Total_Year_1__c != null){
                opp.Amount = opp.Total_Year_1__c;
            }
        }
    }
    
    public static void setOppotunityType(List<Opportunity> newOpportunityList){
        system.debug('newOpportunityList rt:'+newOpportunityList);
        for(Opportunity opp : newOpportunityList){
            String recordTypeDevName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.RecordTypeId).getDeveloperName();
            system.debug('recordTypeDevName rt:'+recordTypeDevName);
            if(recordTypeDevName =='Cross_Sell' || recordTypeDevName =='New_Sale' || 
               recordTypeDevName =='Renewal' || recordTypeDevName =='Up_Sell'){
                   opp.Opportunity_Type__c = 'Commercial';
               }else{
                   opp.Opportunity_Type__c = 'Federal';
               }
            
            //updating Amount field
            if(opp.Total_Year_1__c != null){
                opp.Amount = opp.Total_Year_1__c;
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
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity_Scores__c> getOpportunityQuestions(String opportunityId){
        List<Opportunity_Scores__c> questionList = [Select id,Question__c,Question_Number__c,Answer__c, Category__c, 
                                                    Last_Score_Set__c, Name, Notes__c,Score__c 
                                                    from Opportunity_Scores__c 
                                                    Where Opportunity__c =: opportunityId];
        if(!questionList.isEmpty()){
            return questionList;
        }
        return null;
    }
    
}