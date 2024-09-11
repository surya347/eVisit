public class LeadBatchClass implements Database.Batchable<sObject> {
    
    public List<Lead> leadList = new List<Lead>();
    
    public LeadBatchClass(List<Lead> leadsToUpdate){
       leadList = leadsToUpdate;          
       }
    
    public Iterable<Lead> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return leadList;
    }
    public void execute(Database.BatchableContext bc, List<Lead> leadsToUpdate){
        // process each batch of records
        update leadsToUpdate;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        system.debug('job:'+job);
    }
}