public class Account_CC {



    public static List<Contact> updateContactStatus(List<Account> canceledAccounts) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : canceledAccounts) {
            accountIds.add(acc.Id);
        }

        List<AccountContactRelation> accountContactRelations = [
            SELECT ContactId, AccountId, Account.MissionStatus__c
            FROM AccountContactRelation
            WHERE AccountId IN :accountIds
        ];

        Map<Id, List<AccountContactRelation>> relationsByContact = new Map<Id, List<AccountContactRelation>>();
        for (AccountContactRelation relation : accountContactRelations) {
            if (!relationsByContact.containsKey(relation.ContactId)) {
                relationsByContact.put(relation.ContactId, new List<AccountContactRelation>());
            }
            relationsByContact.get(relation.ContactId).add(relation);
        }


        List<Contact> contactsDisabled = new List<Contact>();
        for (Id contactId : relationsByContact.keySet()) {
            // Vérifie si toutes les missions sont annulées
            Boolean allCanceled = true;
            for (AccountContactRelation relation : relationsByContact.get(contactId)) {
                if (relation.Account.MissionStatus__c != 'canceled') {
                    allCanceled = false;
                    break;
                }
            }
            if (allCanceled) 
                contactsDisabled.add(new Contact(Id = contactId, IsActive__c = false));
        }
        return contactsDisabled;
    }


    public static void commitContactUpdateNSync(List<Contact> contactsToUpdate){
        List<Database.SaveResult> results = Database.update(contactsToUpdate,false);
            List<Contact> contactsToSync = new List<Contact>();
            for(Integer i=0;i<contactsToUpdate.size();i++){
                if(results[i].isSuccess()) contactsToSync.add(contactsToUpdate[i]);
                //else use logging or exceptions
            }
            Account_CC.syncWithAPI(contactsToSync);
    }


    public static void syncWithAPI(List<Contact> contactsToSync) {
        List<String> contactsWithStatus = new List<String>();
        for(Contact contact : contactsToSync) contactsWithStatus.add(''+contact.Id+':'+contact.IsActive__c);
        Account_CC.startSync(contactsWithStatus);
    }

    @future
    public static void commitAccountCancel(List<Id> AccountIds){
        List<Account> accountsToUpdate = [SELECT Id, MissionCanceledDate__c FROM Account WHERE Id IN :AccountIds];
        for (Account acc : accountsToUpdate) {
            acc.MissionCanceledDate__c = Date.today();
        }
        update accountsToUpdate;
    }

    @future(callout=true)
    public static void startSync(List<String> contactsWithStatus){
        //recuperation des Id IsActive__c
        Map<String, String>  contactsIdWithStatus = new Map<String, String>();
        for(String str: contactsWithStatus){
            contactsIdWithStatus.put(str.split(':')[0], str.split(':')[1]);
        }
        
        // Préparation du payload
         List<Map<String, String>> contactsPayload = new List<Map<String, String>>();
         for (String contactKey : contactsIdWithStatus.keySet()) {
             contactsPayload.add(new Map<String, String>{
                 'id' => contactKey,
                 'is_active' => contactsIdWithStatus.get(contactKey)
             });
         }
 
         Http http = new Http();
         HttpRequest request = new HttpRequest();
         request.setEndpoint('callout:contactsSync'); // On utilise une named credential 
         request.setMethod('PATCH');
         request.setHeader('Authorization', 'salesforceAuthToken');
         request.setHeader('Content-Type', 'application/json');
         request.setBody(JSON.serialize(contactsPayload));
 
         try {
             HttpResponse response = http.send(request);
             if (response.getStatusCode() != 200) {
                 System.debug('API Error: ' + response.getBody());
             }
             //Logging is recommanded
             switch on response.getStatusCode() {
                 when 200 {
                     System.debug('Sync OK: ' + response.getBody());
                 }
                 when 404 {
                     System.debug('Error 404 - NotFound: ' + response.getBody());
                 }
                 when 401 {
                     System.debug('Error 401 - Bad authorization.');
                 }
                 when 400 {
                     System.debug('Error 404 -Errors in parameters: must be an array of objects with two properties id:string and is_active:boolean.');
                 }
                 when else {
                     System.debug('Unexpected Error: ' + response.getStatusCode() + ' - ' + response.getBody());
                 }
             }
         } catch (Exception e) {
             System.debug('API Exception: ' + e.getMessage());
         }
    }
}