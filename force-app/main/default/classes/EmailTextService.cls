public with sharing class EmailTextService {

    public static String getTextForSenderWithINN(PaymentTriggerHelper.PaymentInfoWrapper paymentInfo){
        
        String body = 'Dear ' + paymentInfo.con.Name + '!\n     Your payment has been sent succesfully. Information about the payment: \n' + 
        'Recipient - ' + paymentInfo.payment.Recipient__c + '\n' +
        'Amount - ' + paymentInfo.payment.Amount__c + '\n' +
        'Date - ' + paymentInfo.payment.Date_send__c + '\n' + 
        'System - ' + paymentInfo.systemName;

        return body;
    }

    public static String getTextForRecipientWithINN(PaymentTriggerHelper.PaymentInfoWrapper paymentInfo){

        String body = 'Dear ' + paymentInfo.con.Name + '!\n     Your payment has been received succesfully. Information about the payment: \n' + 
        'Sender - ' + paymentInfo.payment.Sender__c + '\n' +
        'Amount - ' + paymentInfo.payment.Amount__c + '\n' +
        'Date - ' + paymentInfo.payment.Date_pay_out__c + '\n' +
        'System - ' + paymentInfo.systemName;
        
        return body;
    }
}