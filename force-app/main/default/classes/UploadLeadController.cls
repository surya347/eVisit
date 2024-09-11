public class UploadLeadController {
    
    public static void dele(){
        List<Lead> leadList = [Select id,name from Lead];
        delete leadList;
    }
    
    //method used to update lead record with its parent lead details from CSV
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

    //method used to update lead record with Definitive data from CSV
    @AuraEnabled
    public static List<Lead> updateLeadsWithDefinitive(Id idContentDocument){
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
                    if(leadDefinitiveIdMap.get(csvRowData[0]) != null){
                        
                        	String genericString;
                            leadObj.Id = leadDefinitiveIdMap.get(csvRowData[0]);
                        	
                            leadObj.DefHC_Hospital_Name__c = csvRowData[1].trim();
                            leadObj.DHC_Provider_Profile__c = csvRowData[2].trim();
                            leadObj.DHC_Provider_Website__c = csvRowData[3].trim();
                            leadObj.DHC_Network_ID__c = csvRowData[4].trim();
                            leadObj.DHC_Network_Name__c = csvRowData[5].trim();
                            leadObj.DHC_Parent_Network_ID__c = csvRowData[6].trim();
                            leadObj.DHC_Parent_Network_Name__c = csvRowData[7].trim();
                        	
                            leadObj.DHC_EMR_Vendor_Ambulatory__c = csvRowData[8].trim();
                        	String s = csvRowData[9].contains('\"')==true ? csvRowData[9].replaceAll('\"', ''):csvRowData[9];
                        	system.debug('csvRowData[9]:'+csvRowData[9]);
                        	system.debug('csvRowData[10]:'+csvRowData[10]);
                            leadObj.DHC_EMR_Vendor_Inpatient__c = s.replaceAll(',', '').trim();
                            leadObj.DHC_of_No_Affiliated_Physicians__c =csvRowData[10] !='' ? Decimal.valueOf(csvRowData[10]) :null;
                            leadObj.DHC_No_of_Beds__c = csvRowData[11] !='' ? Decimal.valueOf(csvRowData[11].replaceAll('\"', '')) :null;
                            leadObj.DHC_No_of_Discharges__c =  csvRowData[12] !='' ?Decimal.valueOf(csvRowData[12]):null;
                            leadObj.DHC_Net_Patient_Revenue__c = csvRowData[13];
                            
                            if(!leadListToUpdate.contains(leadObj)){
                                leadListToUpdate.add(leadObj);
                                
                            }                        
                        }
                        
                    }
                    
                }
            } 
        
        
        try{
            if(!leadListToUpdate.isEmpty()){
                system.debug('leadListToUpdate:'+leadListToUpdate);
                //Id batchId = Database.executeBatch(new LeadBatchClass(leadListToUpdate),200);
                //system.debug('batch id 1:'+batchId);
                return null;
            }
        }catch (Exception ex) {
            System.debug('error:>>'+ex.getMessage());
            //throw new AuraHandledException(ex.getMessage());
            return null;
        } 
        return Null;
    }
    
   
}