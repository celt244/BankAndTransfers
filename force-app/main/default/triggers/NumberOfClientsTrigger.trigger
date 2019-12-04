trigger NumberOfClientsTrigger on Contact (before update, after delete, after insert) {
    NumberOfClientsTriggerHelper helper = new NumberOfClientsTriggerHelper();
    
    if(trigger.isUpdate){
        helper.onBeforeUpdate(trigger.newMap, trigger.oldMap);
    }
	
     if(trigger.isDelete){
        helper.onAfterDelete(trigger.old);
    }
    
    if(trigger.isInsert){
        helper.onAfterInsert(trigger.new);
    }

}