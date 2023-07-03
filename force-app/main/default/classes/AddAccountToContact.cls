/*****************************************************************************
* Name             : AddAccountToContact
* Created By       : Dustin Jensen
* Created Date     : 28 Dec 2017
* Purpose          : Add existing account to it's respective contact
*****************************************************************************/
public class AddAccountToContact {
    
    public static void findExistingContact(List<Contact> newlyCreatedContact) {
        try{
            List<String> LastNameStreetAndZipCode = new List<String>();
            List<Account> existingAcctsList = new List<Account>();
            List<Contact> existingCtList = new List<Contact>();
            List<Account> exsistingAccount = new List<Account>();
            
            for(Contact newContact : newlyCreatedContact) {
                LastNameStreetAndZipCode.add(newContact.LastNameStreetAndZipCode__c);
            }
            
            Map<String, Account> mapOfAccounts = new Map<String, Account>();
            
            Try{ 
                exsistingAccount = [Select Id, LastNameStreetAndZipCode__c FROM Account
                                    WHERE LastNameStreetAndZipCode__c IN : LastNameStreetAndZipCode
                                    AND Duplicate__c = false
                                    AND isDeleted = false
                                    ORDER BY CreatedDate ASC
                                    LIMIT 50000];       
            } catch(Exception exp) {
                CalCas_ErrorLogHandler.createExceptionsLog(exp,'AddAccountToContact','Account query failed');
            }
            
            if(exsistingAccount.size() > 0){
                existingAcctsList.addAll(exsistingAccount);
                
                for(Account acct : existingAcctsList) {
                    mapOfAccounts.put(acct.LastNameStreetAndZipCode__c, acct);
                }
                
                for(Contact updateContact : newlyCreatedContact) {
                    if(mapOfAccounts.containsKey(updateContact.LastNameStreetAndZipCode__c)) {
                        Account retrievedAcctId = mapOfAccounts.get(updateContact.LastNameStreetAndZipCode__c);
                        try {
                            updateContact.AccountID = retrievedAcctId.Id;
                        } catch(Exception exp) {
                            CalCas_ErrorLogHandler.createExceptionsLog(exp,'LeadOwnerAssignment','Affinity Codes did not update');
                        }
                    }
                }
            }
        }catch(Exception exp){
            CalCas_ErrorLogHandler.createExceptionsLog(exp,'AddAccountToContact','Error in adding account to contact class');
        }  
    }
}