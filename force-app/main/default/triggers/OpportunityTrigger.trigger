trigger OpportunityTrigger on Opportunity (before update) {
    
    if(Trigger.IsUpdate){
        if(Trigger.IsBefore){
            //OpportunityController.restrictSelectingPriorStage(Trigger.oldMap ,Trigger.new);
        }
    }

}