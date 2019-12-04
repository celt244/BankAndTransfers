public with sharing class PaymentTriggerHelper {

    public PaymentTriggerHelper() {

    }

    public void onBeforeUpdate (List<Payment__c> payments){
        List<Id> branchIds = new List<Id>();

        for(Payment__c p : payments){
            branchIds.add(p.SourceBrunch__c);
            branchIds.add(p.DestinationBrunch__c);
        } 
        Map<Id, Brunch__c> brunchesMap = new Map<Id, Brunch__c>([SELECT Name, Coffers__c FROM Brunch__c WHERE Id IN : branchIds]);

        for(Payment__c p : payments){
            system.debug(p);
            if(p.Type_of_transaction__c	== 'Cash' && p.Status__c == PaymentStatuses.SENT){
                brunchesMap.get(p.SourceBrunch__c).Coffers__c += p.Amount__c;
            }
            else if(p.Type_of_transaction__c == 'Cash' && p.Status__c == PaymentStatuses.RECEIVED){
               if(p.Amount__c <= brunchesMap.get(p.DestinationBrunch__c).Coffers__c){
                   brunchesMap.get(p.DestinationBrunch__c).Coffers__c -= p.Amount__c;
               } else {
                    p.addError('There is not enough amount in the Brunch to receive this payment. You can go to another brunch or сome back later');
               }
            }
        }
       update  brunchesMap.values();
    }

    public void onAfterUpdate(List<Payment__c> payments){
        List<String> conINN = new List<String>();
        List<Id> systemIds = new List<Id>();

        for(Payment__c p : payments){
            conINN.add(p.SenderINN__c);
            conINN.add(p.RecepientINN__c);
            systemIds.add(p.System__c);
        }

        Map<Payment__c, String> paymentsWithSystems = getPaymentsWithSystemsMap(systemIds, payments);
        Map<String, Contact> innWithContacts = getInnWithContacts(conINN);
        List<PaymentTriggerHelper.paymentInfoWrapper> paymentInfoList = preparePaymentsInfoList(payments, innWithContacts, paymentsWithSystems);
        if(!Test.isRunningTest()){
            sendEmails(paymentInfoList);
        }
        
    }

    public class PaymentInfoWrapper{
        public PaymentInfoWrapper(Payment__c payment, Contact con, String systemName){
            this.payment = payment;
            this.con = con;
            this.systemName = systemName;
        }
        public Payment__c payment;
        public Contact con;
        public String systemName;

    }

    private Map<Payment__c, String> getPaymentsWithSystemsMap(List<Id> systemIds, List<Payment__c> payments){
        Map<Id, System__c> systems = new Map<Id, System__c>([SELECT Id, Name FROM System__c WHERE Id IN :systemIds]);

        Map<Payment__c, String> paymentsWithSystems = new Map<Payment__c, String>();
        for(Payment__c payment : payments){
            paymentsWithSystems.put(payment, systems.get(payment.System__c).Name);
        } 

        return paymentsWithSystems;
    }

    private Map<String, Contact> getInnWithContacts(List<String> conINN){
        List<Contact> contactList = [SELECT Email, Name, INN__c FROM Contact WHERE INN__c IN : conINN];

        Map<String, Contact> innWithContacts = new Map<String, Contact>();
        for(Contact con : contactList){
            innWithContacts.put(con.INN__c, con);
        }
        return innWithContacts;
    }

    private List<PaymentTriggerHelper.paymentInfoWrapper> preparePaymentsInfoList(List<Payment__c> payments, Map<String, Contact> innWithContacts, Map<Payment__c, String> paymentsWithSystems){
        List<PaymentTriggerHelper.paymentInfoWrapper> paymentInfoList = new List<PaymentTriggerHelper.paymentInfoWrapper>();
        for(Payment__c payment : payments){
            if(payment.Status__c == PaymentStatuses.SENT){
                paymentInfoList.add(new PaymentTriggerHelper.paymentInfoWrapper(payment, innWithContacts.get(payment.SenderINN__c), paymentsWithSystems.get(payment)));
            }
            if(payment.Status__c == PaymentStatuses.RECEIVED){
                paymentInfoList.add(new PaymentTriggerHelper.paymentInfoWrapper(payment, innWithContacts.get(payment.RecepientINN__c), paymentsWithSystems.get(payment)));
            }            
        }
        return paymentInfoList;
    }

    private void sendEmails(List<PaymentTriggerHelper.paymentInfoWrapper> paymentInfoList){
        for(PaymentTriggerHelper.paymentInfoWrapper paymentInfo : paymentInfoList){
            if(paymentInfo.payment.Status__c == PaymentStatuses.SENT){
                EmailService.sendToSender(paymentInfo);
            }
            if(paymentInfo.payment.Status__c == PaymentStatuses.RECEIVED){
                EmailService.sendToRecipient(paymentInfo);
            }            
        }
    }
}