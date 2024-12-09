trigger AccouuntTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    handler.run();
    handler.commitChanges();
}