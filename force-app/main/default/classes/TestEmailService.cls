@isTest
public with sharing class TestEmailService {
    @TestSetup
    static void initData(){

        Contact sender = new Contact(LastName = 'Sender', INN__c = 'A1A1A1A1A1',  Email='aaa@bbb.ccc');
        insert sender;
        Contact recepient = new Contact(LastName = 'Recipient', INN__c = 'R1R1R1R1R1', Email ='bbb@bbb.ccc');
        insert recepient;

        List<Payment__c> payments = new List<Payment__c>();
        // Sent payment from Sender to Recipient
        payments.add(new Payment__c(Amount__c=200, Date_send__c=system.now(), Sender__c='Sender', Recipient__c='Recipient', 
                    Type_of_transaction__c='Cash',RecepientINN__c='R1R1R1R1R1',SenderINN__c='A1A1A1A1A1',Status__c='Sent'));
        // Payment that already stored in history Recipient
        payments.add(new Payment__c(Amount__c=300, Date_send__c=system.now(), Date_pay_out__c=system.now(), Sender__c='Sender', Recipient__c='Recipient', 
                    Type_of_transaction__c='Cash',RecepientINN__c='R1R1R1R1R1',SenderINN__c='A1A1A1A1A1', Status__c='Received'));
        insert payments;


    }
     @isTest
    static void testEmailServiceSendToSenderWihtError(){

        //given
        Contact sender = [SELECT Name, LastName, INN__c, Email FROM Contact LIMIT 1];
        sender.Email = null;
        update sender;
        List<Payment__c> payments = [SELECT Amount__c, Recipient__c, Date_send__c FROM Payment__c]; 

        PaymentTriggerHelper.PaymentInfoWrapper paymentInfo = new PaymentTriggerHelper.PaymentInfoWrapper(payments[0],sender,'MoneyGram');

        try{
            EmailService.sendToSender(paymentInfo);
        }
        catch(Exception ex){
            System.assert(ex.getMessage().contains('INVALID_EMAIL_ADDRESS'));
        }
        
    }

    @isTest
    static void testEmailServiceSendToRecipientWihtError(){


        //given
        Contact recepient = [SELECT Name, LastName, INN__c, Email FROM Contact LIMIT 1];
        recepient.Email = null;
        update recepient;
        List<Payment__c> payments = [SELECT Amount__c, Sender__c, Date_pay_out__c FROM Payment__c]; 

        PaymentTriggerHelper.PaymentInfoWrapper paymentInfo = new PaymentTriggerHelper.PaymentInfoWrapper(payments[0],recepient,'MoneyGram');

        try{
            EmailService.sendToRecipient(paymentInfo);
        }
        catch(Exception ex){
            system.debug(ex);
            System.assert(ex.getMessage().contains('INVALID_EMAIL_ADDRESS'));
        }
    }


    @isTest
    static void testEmailServiceSuccessfullySendToSender(){

        //given
        Contact sender = new Contact(LastName = 'Sender', INN__c = 'A1A1A1A1A1', Email='aaabbbcccqqqttt@yopmail.com');
        Contact recepient = new Contact(LastName = 'Recipient', INN__c = 'R1R1R1R1R1', Email ='bbb@bbb.ccc');
        List<Payment__c> payments = [SELECT Amount__c, Recipient__c, Sender__c, Date_send__c, Date_pay_out__c FROM Payment__c]; 

        PaymentTriggerHelper.PaymentInfoWrapper paymentInfo = new PaymentTriggerHelper.PaymentInfoWrapper(payments[0],sender,'MoneyGram');

        Integer expected = Limits.getEmailInvocations();
        EmailService.sendToSender(paymentInfo);
        Integer actualInvocations = Limits.getEmailInvocations();
 
        System.assertEquals(expected + 1, actualInvocations, 'An email has been successfully sent to sender');
    }

    @isTest
    static void testEmailServiceSuccessfullySendToRecipient(){

        //given
        Contact sender = new Contact(LastName = 'Sender', INN__c = 'A1A1A1A1A1', Email='aaa@bbb.ccc');
        Contact recepient = new Contact(LastName = 'Recipient', INN__c = 'R1R1R1R1R1', Email ='aaabbbcccqqqttt@yopmail.com');
        List<Payment__c> payments = [SELECT Amount__c, Recipient__c, Sender__c, Date_pay_out__c, Date_send__c FROM Payment__c WHERE Recipient__c='Recipient']; 

        PaymentTriggerHelper.PaymentInfoWrapper paymentInfo = new PaymentTriggerHelper.PaymentInfoWrapper(payments[0],sender,'MoneyGram');

        Integer expected = Limits.getEmailInvocations();
        EmailService.sendToSender(paymentInfo);
        Integer actualInvocations = Limits.getEmailInvocations();
 
        System.assertEquals(expected + 1, actualInvocations, 'An email has been successfully sent to recipient');
    }
    
}