trigger OpportunityTrigger on Opportunity (before insert,before update) {
    
     if(Trigger.IsInsert){
        if(Trigger.IsBefore){
            OpportunityController.setOppotunityType(Trigger.new);
        }
    }
    if(Trigger.IsUpdate){
        if(Trigger.IsBefore){
            OpportunityController.restrictSelectingPriorStage(Trigger.oldMap ,Trigger.new);
        }
    }

}