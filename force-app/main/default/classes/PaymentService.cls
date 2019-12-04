public with sharing class PaymentService {
    public static Id createPayment(PaymentStructure payment){
        Payment__c newPayment = new Payment__c();
        newPayment.SourceBrunch__c = payment.sourceBranch;
        newPayment.Status__c = payment.paymentStatus;
        newPayment.Sender__c = payment.senderName;
        newPayment.SenderINN__c = payment.senderINN;
        insert newPayment;
        return newPayment.Id;
    }

    public static void updatePayment(PaymentStructure payment){
        Payment__c paymentToUpdate = [SELECT Amount__c, DestinationBrunch__c, Date_pay_out__c, Date_send__c, Recipient__c, Sender__c, Status__c, System__c, Type_of_transaction__c, RecepientINN__c
                              FROM Payment__c
                              WHERE Id = :payment.paymentId];
        paymentToUpdate.Amount__c = payment.amount != null ? payment.amount : paymentToUpdate.Amount__c;
        paymentToUpdate.Date_pay_out__c = payment.datePayOut != null ? payment.datePayOut : paymentToUpdate.Date_pay_out__c;
        paymentToUpdate.Date_send__c = payment.dateSend != null ? payment.dateSend : paymentToUpdate.Date_send__c;
        paymentToUpdate.Recipient__c = payment.recipientName != null ? payment.recipientName : paymentToUpdate.Recipient__c;
        paymentToUpdate.Status__c = payment.paymentStatus != null ? payment.paymentStatus : paymentToUpdate.Status__c;
        paymentToUpdate.System__c = payment.paymentSystem != null ? payment.paymentSystem : paymentToUpdate.System__c;
        paymentToUpdate.Type_of_transaction__c = payment.type != null ? payment.type : paymentToUpdate.Type_of_transaction__c;
        paymentToUpdate.RecepientINN__c = payment.recipientINN != null ? payment.recipientINN : paymentToUpdate.RecepientINN__c;
        paymentToUpdate.DestinationBrunch__c = payment.destinationBranch != null ? payment.destinationBranch : paymentToUpdate.DestinationBrunch__c;
        update paymentToUpdate;
    }

    public static List<Payment__c> getInboundPayments(String recipientINN, Id brunch, Boolean isTerrorist){
        List<Payment__c> payments = new List<Payment__c>();
        if(!isTerrorist){
            Brunch__c br = [SELECT ParentBank__c FROM Brunch__c WHERE Id = :brunch];
            Bank__c bank = [SELECT Id, Name, (SELECT System__c, System__r.Name FROM System_Selection__r) From Bank__c WHERE Id = :br.ParentBank__c LIMIT 1];
            system.debug(bank);
            Set<String> systems = new Set<String>(); 
            for(System_Selection__c sys : bank.System_Selection__r){
                systems.add(sys.System__r.Name);
            }  

            payments = [SELECT Id, Amount__c, Date_send__c, Sender__c, Recipient__c, System__r.Name, Status__c, Type_of_transaction__c, RecepientINN__c, SenderINN__c, DestinationBrunch__c FROM Payment__C
                                        WHERE System__r.Name IN :systems AND RecepientINN__c = :recipientINN AND Status__c = :PaymentStatuses.SENT];

        }
        
        return payments;
    }

    public static List<Payment__c> getOutboundPayments(String senderINN){
        List<Payment__c> payments = [SELECT Id, Amount__c, Date_send__c, Sender__c, Recipient__c, System__r.Name, Status__c, Type_of_transaction__c, RecepientINN__c, SenderINN__c FROM Payment__C
                                    WHERE SenderINN__c = :senderINN AND Status__c = :PaymentStatuses.SENT];
        return payments;
    }

    public static List<Payment__c> getPaymentHistory(String INN){
        List<Payment__c> payments = [SELECT Id, Amount__c, Date_send__c, Sender__c, Recipient__c, System__r.Name, Status__c, Type_of_transaction__c, RecepientINN__c, SenderINN__c FROM Payment__C
                                    WHERE (SenderINN__c = :INN OR RecepientINN__c = :INN) AND Status__c = :PaymentStatuses.RECEIVED];
        return payments;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}