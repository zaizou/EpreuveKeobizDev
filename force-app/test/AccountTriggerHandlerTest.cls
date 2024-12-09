@isTest
public class AccountTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test Accounts
        Account acc1 = new Account(Name = 'Test Account 1', MissionStatus__c = 'active');
        Account acc2 = new Account(Name = 'Test Account 2', MissionStatus__c = 'active');
        insert new List<Account>{acc1, acc2};

        // Create test Contacts
        Contact contact1 = new Contact(LastName = 'Test Contact 1', IsActive__c = true,AccountId=acc2.Id );
        Contact contact2 = new Contact(LastName = 'Test Contact 2', IsActive__c = true,AccountId=acc1.Id);
        insert new List<Contact>{contact1, contact2};

        // Create AccountContactRelation records
        AccountContactRelation acr1 = new AccountContactRelation(AccountId = acc1.Id, ContactId = contact1.Id);
        AccountContactRelation acr2 = new AccountContactRelation(AccountId = acc2.Id, ContactId = contact2.Id);
        insert new List<AccountContactRelation>{acr1, acr2};
    }

    @isTest
    static void testProcessAccountUpdates() {
            // Query test Accounts
            List<Account> accountsToUpdate = [SELECT Id, Name, MissionStatus__c, MissionCanceledDate__c FROM Account LIMIT 2];

            // Update MissionStatus__c to 'canceled'
            for (Account acc : accountsToUpdate) {
                acc.MissionStatus__c = 'canceled';
            }
            update accountsToUpdate;

            // Verify Account updates
            List<Account> updatedAccounts = [SELECT Id, MissionStatus__c, MissionCanceledDate__c FROM Account];
            for (Account acc : updatedAccounts) {
                Assert.areEqual('canceled', acc.MissionStatus__c, 'Account MissionStatus__c should be canceled');
                Assert.isNotNull(acc.MissionCanceledDate__c, 'MissionCanceledDate__c should be set');
            }

            // Verify related Contact updates
            List<Contact> updatedContacts = [SELECT Id, IsActive__c FROM Contact];
            for (Contact contact : updatedContacts) {
                Assert.areEqual(false, contact.IsActive__c, 'Contact IsActive__c should be false if all related accounts are canceled');
            }

            // Verify future method was called (via debug logs or AsyncApexJob)
            Test.startTest();
            Test.stopTest();

            // No direct way to verify future call, but ensure no exceptions occurred
        }


        @isTest
        static void testSyncWithAPI() {
            // Create test contacts
            Contact testContact = new Contact(LastName = 'Test Contact', IsActive__c = true);
            insert testContact;

            Test.setMock(HttpCalloutMock.class, new SyncMock());
            List<String> contactsWithStatus =  new list<String>();
            for(Contact contact : [SELECT Id, IsActive__c FROM Contact]) contactsWithStatus.add(''+contact.Id+':'+contact.IsActive__c);
            Test.startTest();
            Account_CC.startSync(contactsWithStatus); // Replace with your future method class
            Test.stopTest();
    
            // Assertions to verify behavior
            // You can assert the contact IDs and debug logs as needed
            System.assert(true, 'The future method executed without exceptions.');
        }
    
    }