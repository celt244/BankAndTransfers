public with sharing class EmailService {


    public static void sendToSender(PaymentTriggerHelper.PaymentInfoWrapper paymentInfo){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {paymentInfo.con.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('To Send Payment Form');
        mail.plainTextBody = EmailTextService.getTextForSenderWithINN(paymentInfo);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendToRecipient(PaymentTriggerHelper.PaymentInfoWrapper paymentInfo){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {paymentInfo.con.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('To Receive Payment Form');
        mail.plainTextBody = EmailTextService.getTextForRecipientWithINN(paymentInfo);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @future
    public static void sendEmailToMe(String emailAddress){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailAddress};
        mail.setToAddresses(toAddresses);
        mail.setSubject('It\'s been sent from a future method!!!');
        mail.plainTextBody = 'It\'s been sent from a future method!!!';
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}