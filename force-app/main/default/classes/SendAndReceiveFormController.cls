public with sharing class SendAndReceiveFormController {

    public String recipientName {get;set;}
    public Boolean newPayment {get;set;}
    public Decimal amount {get;set;} 
    public String type {get; set;}
    public String paymentSystem {get; set;}
    public String recipientINN {get;set;}
    public List<PaymentStructureWrapper> inboundPayments {get;set;}
    public List<PaymentStructureWrapper> outboundPayments {get;set;}
    public List<PaymentStructureWrapper> oldPayments {get;set;}
    

    private Id currentPaymentId;
    private Contact theGuy;
    

    public SendAndReceiveFormController(ApexPages.StandardController controller) {
        this.theGuy = (Contact)controller.getRecord();
        newPayment = false;
        this.theGuy = [SELECT Brunch__c, Name, INN__c, Terrorist__c	FROM Contact WHERE Id = :theGuy.Id];
        inboundPayments = getInboundPaymentPlease();
        outboundPayments = getOutboundPayment();
        oldPayments = getPaymentHistory();
    }

    public Pagereference createPayment(){
        newPayment = true;        
        PaymentStructure paymentToCreate = new PaymentStructure();
        paymentToCreate.paymentStatus = PaymentStatuses.CREATED;
        paymentToCreate.sourceBranch = theGuy.Brunch__c;
        paymentToCreate.senderName = theGuy.Name;
        paymentToCreate.senderINN = theGuy.INN__c;
        currentPaymentId = PaymentService.createPayment(paymentToCreate);
        return null;
    }

    public List<SelectOption> getTypes(){
        List<SelectOption> types = new List<SelectOption>(); 
        types.add(new SelectOption('Cash','Cash'));
        types.add(new SelectOption('Cashless', 'Cashless'));
        return types;
    }

    public List<SelectOption> getPaymentStatuses(){
        List<SelectOption> statuses = new List<SelectOption>(); 
        statuses.add(new SelectOption(PaymentStatuses.RECEIVED,'Sent'));
        statuses.add(new SelectOption(PaymentStatuses.RECEIVED, 'Received'));
        return statuses;
    }

    public List<SelectOption> getSystems(){
        Brunch__c br = [SELECT ParentBank__c FROM Brunch__c WHERE Id = :theGuy.Brunch__c];
        Bank__c bank = [SELECT Id, Name, (SELECT System__c, System__r.Name FROM System_Selection__r) From Bank__c WHERE Id = :br.ParentBank__c LIMIT 1];
        List<SelectOption> systems = new List<SelectOption>(); 
        for(System_Selection__c sys : bank.System_Selection__r){
            systems.add(new SelectOption(sys.System__c, sys.System__r.Name));
        }        
        return systems;
    }

    public Pagereference sendPayment(){
        if(String.isBlank(recipientName) && !String.isBlank(recipientINN)){
            recipientName = [SELECT Name, INN__c FROM Contact WHERE INN__c = :recipientINN LIMIT 1].Name;
        }
        PaymentStructure paymentToSend = new PaymentStructure();
        paymentToSend.dateSend = System.now();
        paymentToSend.amount = amount;
        paymentToSend.recipientName = recipientName;
        paymentToSend.type = type;
        paymentToSend.paymentSystem = paymentSystem;
        paymentToSend.recipientINN = recipientINN;
        paymentToSend.paymentStatus = PaymentStatuses.SENT;
        paymentToSend.paymentId = currentPaymentId;
        system.debug(paymentToSend);
        PaymentService.updatePayment(paymentToSend);
        system.debug(paymentToSend);
        newPayment = false;
        return null;
    }

    public Pagereference payMarkedItems(){
        List<PaymentStructure> paymentsToUpdate = new List<PaymentStructure>();
        for(PaymentStructureWrapper item : inboundPayments){
            System.debug(item);
            if(item.status != PaymentStatuses.SENT){
                PaymentStructure payment = new PaymentStructure();
                payment.paymentStatus = item.status;
                payment.paymentId = item.paymentId;
                payment.datePayOut = system.now();
                payment.destinationBranch = theGuy.Brunch__c;
                payment.paymentStatus = item.status;
                try{
                    PaymentService.updatePayment(payment);
                }
                catch(DmlException e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0)));
                }
                
            }
        }
        
        return null;
    }

    public List<PaymentStructureWrapper> getInboundPaymentPlease(){
        system.debug('mIN');
        List<PaymentStructureWrapper> payments = new List<PaymentStructureWrapper>();
        List<Payment__c> payment = PaymentService.getInboundPayments(theGuy.INN__c, theGuy.Brunch__c, theGuy.Terrorist__c);
        system.debug(payment);
        for(Payment__c p : payment){
            PaymentStructureWrapper tempPayment = new PaymentStructureWrapper();
            tempPayment.amount = p.Amount__c;
            tempPayment.dateSend = p.Date_send__c;
            tempPayment.senderName = p.Sender__c;
            tempPayment.recipientName = p.Recipient__c;
            tempPayment.type = p.Type_of_transaction__c;
            tempPayment.recipientINN = p.RecepientINN__c;
            tempPayment.senderINN = p.SenderINN__c;
            tempPayment.status = p.Status__c;
            tempPayment.paymentId = p.Id;
            tempPayment.destinationBranch = p.DestinationBrunch__c;

            payments.add(tempPayment);
        }
        return payments;
    }

    public List<PaymentStructureWrapper> getOutboundPayment(){
        List<PaymentStructureWrapper> payments = new List<PaymentStructureWrapper>();
        List<Payment__c> payment = PaymentService.getOutboundPayments(theGuy.INN__c);
        system.debug(payment);
        for(Payment__c p : payment){
            PaymentStructureWrapper tempPayment = new PaymentStructureWrapper();
            tempPayment.amount = p.Amount__c;
            tempPayment.dateSend = p.Date_send__c;
            tempPayment.senderName = p.Sender__c;
            tempPayment.recipientName = p.Recipient__c;
            tempPayment.type = p.Type_of_transaction__c;
            tempPayment.recipientINN = p.RecepientINN__c;
            tempPayment.senderINN = p.SenderINN__c;
            payments.add(tempPayment);
        }
        return payments;
    }

    public List<PaymentStructureWrapper> getPaymentHistory(){
        List<PaymentStructureWrapper> payments = new List<PaymentStructureWrapper>();
        List<Payment__c> payment = PaymentService.getPaymentHistory(theGuy.INN__c);
        system.debug(payment);
        for(Payment__c p : payment){
            PaymentStructureWrapper tempPayment = new PaymentStructureWrapper();
            tempPayment.amount = p.Amount__c;
            tempPayment.dateSend = p.Date_send__c;
            tempPayment.senderName = p.Sender__c;
            tempPayment.recipientName = p.Recipient__c;
            tempPayment.type = p.Type_of_transaction__c;
            tempPayment.recipientINN = p.RecepientINN__c;
            tempPayment.senderINN = p.SenderINN__c;
            payments.add(tempPayment);
        }
        return payments;
    }

    public with sharing class PaymentStructureWrapper {
        
        public Decimal amount{get;set;}        
        public Datetime dateSend{get;set;}
        
        public String senderName{get;set;}
        public String recipientName{get;set;}
        
        public String type{get;set;}
        public String status{get;set;}

        public String recipientINN{get;set;}
        public String senderINN{get;set;}

        public Id paymentId;
        public Id destinationBranch;
    }


    
}