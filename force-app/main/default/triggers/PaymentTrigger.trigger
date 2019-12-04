trigger PaymentTrigger on Payment__c (before update, after update) {

    PaymentTriggerHelper helper = new PaymentTriggerHelper();

    if(Trigger.isUpdate){
        if(trigger.isBefore){
            helper.onBeforeUpdate(trigger.new);
        }
        if(trigger.isAfter){
            helper.onAfterUpdate(trigger.new);
        }    
    }



}