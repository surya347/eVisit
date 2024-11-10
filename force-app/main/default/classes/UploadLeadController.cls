public class UploadLeadController {
    
    public static void dele(){
        List<Lead> leadList = [Select id,name from Lead];
        delete leadList;
    }
    
    @AuraEnabled
    public static List<Lead> readCSVFileToUpdateParentLeads(Id idContentDocument){
        List<Lead> leadList = [Select Id,Name,texcellency__DefHC_HospitalID__c from Lead];
        List<Lead> leadListToUpdate = new List<Lead>();
        
        Set<String> str =  new Set<String>();
        
        Map<Id,Lead> candidateMap = new  Map<Id,Lead>(leadList);
        Map<String,String> leadDefinitiveIdMap = new  Map<String,String>();
        
        if(!leadList.isEmpty()){
            for(Lead leadObj : leadList){
                if(leadObj.texcellency__DefHC_HospitalID__c !=null){
                    str.add(string.valueof(leadObj.texcellency__DefHC_HospitalID__c));
                    leadDefinitiveIdMap.put(string.valueof(leadObj.texcellency__DefHC_HospitalID__c),leadObj.Id);
                }
            }
            system.debug('str:'+str);
            system.debug('leadDefinitiveIdMap:'+leadDefinitiveIdMap);
        }
        
        
        if(idContentDocument != null) {
            system.debug('idContentDocument:'+idContentDocument);
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            system.debug('objVersions:'+objVersion);
            
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
            System.debug('lstCSVLines====> '+lstCSVLines);
            
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                Lead leadObj = new Lead();
                Lead parentleadObj = new Lead();
                list<String> csvRowData = lstCSVLines[i].split(',');
                System.debug('csvRowData====> '+csvRowData);
                
                if(str.contains(csvRowData[0])){  
                    if((leadDefinitiveIdMap.get(csvRowData[0]) != null) && (leadDefinitiveIdMap.get(csvRowData[1]) != null)){
                        if(leadDefinitiveIdMap.get(csvRowData[0]) != leadDefinitiveIdMap.get(csvRowData[1])){
                            leadObj.Id = leadDefinitiveIdMap.get(csvRowData[0]);
                            leadObj.Parent_Lead__c = leadDefinitiveIdMap.get(csvRowData[1]);
                            if((leadDefinitiveIdMap.get(csvRowData[1].trim()) != null) && (leadDefinitiveIdMap.get(csvRowData[2].trim()) != null)){
                                if(leadDefinitiveIdMap.get(csvRowData[1].trim()) != leadDefinitiveIdMap.get(csvRowData[2].trim())){
                                    leadObj.Ultimate_Parent_Lead__c = leadDefinitiveIdMap.get(csvRowData[2].trim());
                                }
                            }
                            if(!leadListToUpdate.contains(leadObj)){
                                leadListToUpdate.add(leadObj);
                                
                            }                        
                        }
                        
                    }
                    
                }
            }
        }  
        
        
        try{
            if(!leadListToUpdate.isEmpty()){
                system.debug('leadListToUpdate:'+leadListToUpdate);
                Id batchId = Database.executeBatch(new LeadBatchClass(leadListToUpdate),200);
                system.debug('batch id 1:'+batchId);
                return null;
            }
        }catch (Exception ex) {
            System.debug('error:>>'+ex.getMessage());
            //throw new AuraHandledException(ex.getMessage());
            return null;
        } 
        return Null;
    }
    
   /* @AuraEnabled
    public static List<Lead> readCSVFileToUpdateUltimateParentLeads(Id idContentDocument){
        List<Lead> leadLists = [Select Id,Name,texcellency__DefHC_HospitalID__c from Lead];
        List<Lead> parentleadListToUpdate = new List<Lead>();
        
        Set<String> strSet =  new Set<String>();
        Map<String,String> leadDefinitiveIdMaps = new  Map<String,String>();
        
        if(!leadLists.isEmpty()){
            for(Lead leadObj : leadLists){
                if(leadObj.texcellency__DefHC_HospitalID__c !=null){
                    strSet.add(string.valueof(leadObj.texcellency__DefHC_HospitalID__c));
                    leadDefinitiveIdMaps.put(string.valueof(leadObj.texcellency__DefHC_HospitalID__c),leadObj.Id);
                }
            }
            system.debug('strSet:'+strSet);
            system.debug('leadDefinitiveIdMaps:'+leadDefinitiveIdMaps);
        }
        
        
        if(idContentDocument != null) {
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
            System.debug('lstCSVLines====> '+lstCSVLines);
            
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                Lead leadObj = new Lead();
                Lead parentleadObj = new Lead();
                list<String> csvRowDatas = lstCSVLines[i].split(',');
                
                if(strSet.contains(csvRowDatas[1])){
                    //System.debug('csvRowData====> '+leadDefinitiveIdMaps.get(csvRowDatas[1])+ '-'+leadDefinitiveIdMaps.get(csvRowDatas[2]));
                    if((leadDefinitiveIdMaps.get(csvRowDatas[1]) != null) && (leadDefinitiveIdMaps.get(csvRowDatas[2].trim()) != null)){
                        if(leadDefinitiveIdMaps.get(csvRowDatas[1]) != leadDefinitiveIdMaps.get(csvRowDatas[2].trim())){
                            System.debug('call 1');
                            parentleadObj.Id = leadDefinitiveIdMaps.get(csvRowDatas[1]);
                            parentleadObj.Parent_Lead__c = leadDefinitiveIdMaps.get(csvRowDatas[2].trim());
                            if(!parentleadListToUpdate.contains(parentleadObj)){
                                System.debug('call2');
                                parentleadListToUpdate.add(parentleadObj);
                                //Id batchId2 = Database.executeBatch(new LeadBatchClass(parentleadListToUpdate));
                                //system.debug('batch id 2:'+batchId2);
                            }
                        }
                    }
                }
            }
        }  
        try{
            if(!parentleadListToUpdate.isEmpty()){
                system.debug('parentleadListToUpdate:'+parentleadListToUpdate);
                Id batchId2 = Database.executeBatch(new LeadBatchClass(parentleadListToUpdate),200);
                system.debug('batch id 2:'+batchId2);
                return null;
            } 
        }catch (Exception ex) {
            System.debug('error:>>'+ex.getMessage());
            //throw new AuraHandledException(ex.getMessage());
            return null;
        } 
        return Null;
        
    }*/
}