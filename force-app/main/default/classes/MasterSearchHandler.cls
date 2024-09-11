public class MasterSearchHandler {
    
    @AuraEnabled(Cacheable = true)
    public static List<sObject> getSearchData(String searchKey,String searchField,String objectName ) {
        system.debug('searchKey:'+searchKey);
        try {
            String queries='';
            List<sObject> sobjList = new  List<sObject>();
            if(searchKey==''){
                //queries ='SELECT  Id, Name,Email From '+objectName+'';
                return null;
            }else{
                String searchKeys = '%' + searchKey + '%';
                queries = 'SELECT  Id,'+searchField+' From '+ objectName +' WHERE '+searchField+' LIKE :searchKeys';
            }
            sobjList = Database.query(queries);
            if(!sobjList.isEmpty()){
                return sobjList; 
            }
            return null; 
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null; 
        }
    }
    
    @AuraEnabled
    public static List<sObject> getAllData(String objectName ) {
        system.debug('objectName:'+objectName);
        try {
            List<sObject> sobjList = new  List<sObject>();
            String queries = 'SELECT  Id, Name,Email From '+ objectName +'';
            
            sobjList = Database.query(queries);
            if(!sobjList.isEmpty()){
                return sobjList; 
            }
            return null; 
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null; 
        }
    }
}