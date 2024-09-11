/******************************************************************************
Author:Ryan O'Sullivan
Company:CloudKettle
Test Class(s):CK_StageTrackerTest
Description:Test factory for creating records used in test classes

History:
 Date:2018-05-29
 By:Ryan O'Sullivan
 Action:Created
******************************************************************************/
public class CK_TestFactory {

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-29
    Description:Create a defined number of non inserted test leads
    
    Inputs:Integer number of desired leads
    Outputs:List of leads (not inserted into the system)
    *****************************************************************/
    static public Lead[] createLeads(Integer numberOfLeads){
        Lead[] rtnLeads = new Lead[]{};

        numberOfLeads = Math.abs(numberOfLeads);
        numberOfLeads = numberOfLeads == 0 ? 1 : numberOfLeads;
        for(Integer i = 0; i < numberOfLeads; i++){
            rtnLeads.add(new Lead (
                lastName = 'test' + String.valueof(i),
                Company = 'test' + String.valueof(i) 
            ));
        }
        return rtnLeads;
    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-29
    Description:Create a defined number of non inster test Accounts
    
    Inputs:Integer number of desired accounts
    Outputs:List of accounts (not insterted into the system)
    *****************************************************************/
    static public Account[] createAccounts(Integer numberOfAccounts){
        Account[] rtnAccounts = new Account[]{};

        numberOfAccounts = Math.abs(numberOfAccounts);
        numberOfAccounts = numberOfAccounts == 0 ? 1 : numberOfAccounts;
        for(Integer i = 0; i < numberOfAccounts; i++){
            rtnAccounts.add(new Account (
                Name = 'test' + String.valueof(i)
            ));
        }
        return rtnAccounts;
    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-29
    Description:Create a definied number of non inserted test Opps
    
    Inputs:Integer number of deisired Opps
            Id of the account the opps relate to
    Outputs:List of Opps (not inserted into the system)
    *****************************************************************/
    static public Opportunity[] createOpportunities(Integer numberOfOpportunities, Id AccountId){
        Opportunity[] rtnOpportunities = new Opportunity[]{};

        numberOfOpportunities = Math.abs(numberOfOpportunities);
        numberOfOpportunities = numberOfOpportunities == 0 ? 1 : numberOfOpportunities;
        for(Integer i = 0; i < numberOfOpportunities; i++){
            rtnOpportunities.add(new Opportunity (
                Name = 'test' + String.valueof(i),
                AccountId = AccountId,
                CloseDate = Date.today().addDays(5),
                Amount = 5,
                StageName = getRandomPicklistValue(Opportunity.sObjectType, 'StageName', '')
            ));
        }
        return rtnOpportunities;
    }

    /*************************Method**********************************
    Author:Ryan O'Sullivan
    CreatedDate:2018-05-29
    Description:Create a definied number of non inserted test Opps
    
    Inputs:Integer number of deisired Opps
            Id of the account the opps relate to
    Outputs:List of Opps (not inserted into the system)
    *****************************************************************/
    static public Case[] createCases(Integer numberOfCases, Id AccountId){
        Case[] rtnCases = new Case[]{};

        numberOfCases = Math.abs(numberOfCases);
        numberOfCases = numberOfCases == 0 ? 1 : numberOfCases;
        for(Integer i = 0; i < numberOfCases; i++){
            rtnCases.add(new Case (
                AccountId = AccountId
            ));
        }
        return rtnCases;
    }


    public static String getRandomPicklistValue(Schema.sObjectType objectType, String pickListFieldAPIName,String excludeValue){
		Schema.PicklistEntry[] picklistEntries = objectType.getDescribe().fields.getMap().get(pickListFieldAPIName).getDescribe().getPicklistValues();
		if(picklistEntries.size() <= 1)
			throw new CK_StageTracker.IncorrectSchemaException(pickListFieldAPIName + ' on ' + objectType + 'has less then 2 values, cannot measure change in test class');
		// Removed excluded value
		for(Integer i = 0; i < picklistEntries.size(); i++){
			if(picklistEntries[i].getLabel() == excludeValue){
				picklistEntries.remove(i);
				break;
			}
		}
		
		Integer randomNum = Math.round(Math.random()*(picklistEntries.size()-1));
		return picklistEntries[randomNum].getLabel();
	}
    
}