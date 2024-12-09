public  class AccountTriggerHandler  extends TriggerHandler{
    private Map<Id, Account> newMap;
    private Map<Id, Account> oldMap;
    private List<Account> newList;
    private List<Account> oldList;
    private List<Account> accountsToUpdate = new List<Account>();
    private List<Account> accountsToCancel = new List<Account>();
    private List<Contact> contactsToUpdate = new List<Contact>();


    
    public AccountTriggerHandler() {
        this.newMap = (Map<Id, Account>) Trigger.newMap;
        this.oldMap = (Map<Id, Account>) Trigger.oldMap;
        this.newList = Trigger.new;
        this.oldList = Trigger.old;
        this.accountsToUpdate = new List<Account>();
    }

    public Boolean isMissionStatusChanged(Id accountId){
        return this.oldMap.get(accountId).MissionStatus__c!=this.newMap.get(accountId).MissionStatus__c;
    }

    public  Boolean isMissionStatusCanceled(Account account){
        return account.MissionStatus__c == 'canceled';
    }

    public override void afterUpdate(){
        for(Account acc : this.newList){
            //check if the field was changed
            if(isMissionStatusChanged(acc.Id) && isMissionStatusCanceled(acc)){  ///The Active status need to be discussed if we    
                accountsToCancel.add(acc);                                       ///want to activate contacts after having  one active account
            }
        }
        contactsToUpdate.addAll(Account_CC.updateContactStatus(accountsToCancel));
    }
    

    public override void commitChanges(){
        if(accountsToCancel.size()>0) {
            List<Id> accountsIds = new List<Id>();
            for(Account acc : accountsToCancel) accountsIds.add(acc.Id);
            Account_CC.commitAccountCancel(accountsIds);
            this.accountsToCancel = new List<Account>();
        }
        //add code for AccountsToUpdate for another use case
        if(contactsToUpdate.size()>0){
            Account_CC.commitContactUpdateNSync(contactsToUpdate);
            this.contactsToUpdate = new List<Contact>();
        }
    }
}