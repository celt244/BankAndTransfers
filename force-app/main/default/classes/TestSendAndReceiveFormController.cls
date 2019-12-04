@isTest
public class TestSendAndReceiveFormController {
    
    static PageReference page;
    static SendAndReceiveFormController controller;
    

    @TestSetup
    static void initData(){
        System__c systems = new System__c(Name='MoneyGram');
        insert systems;
        Bank__c bank = new Bank__c(Name='PrivatBank');
        insert bank;
        System_Selection__c sb = new System_Selection__c(Bank__c=bank.Id, System__c=systems.Id);
        insert sb;
        Brunch__c branch = new Brunch__c(Name='First',ParentBank__c=bank.Id, Coffers__c=100000);
        insert branch;
        Contact cont = new Contact(LastName = 'Sender', INN__c = 'A1A1A1A1A1', Brunch__c = branch.Id, Email='aaa@bbb.ccc');
        insert cont;
        Contact reCont = new Contact(LastName = 'Recipient', INN__c = 'R1R1R1R1R1', Brunch__c = branch.Id, Email ='bbb@bbb.ccc');
        insert reCont;
        
        List<Payment__c> payments = new List<Payment__c>();
        // Sent payment from Sender to Recipient
        payments.add(new Payment__c(Amount__c=200, Date_send__c=system.now(), Sender__c='Sender', Recipient__c='Recipient', 
                     Type_of_transaction__c='Cash',RecepientINN__c='R1R1R1R1R1',SenderINN__c='A1A1A1A1A1',SourceBrunch__c=branch.Id,
                    DestinationBrunch__c=branch.Id,Status__c='Sent', System__c=systems.Id));
        // Payment that already stored in history Recipient
        payments.add(new Payment__c(Amount__c=300, Date_send__c=system.now(), Date_pay_out__c=system.now(), Sender__c='Sender', Recipient__c='Recipient', 
                     Type_of_transaction__c='Cash',RecepientINN__c='R1R1R1R1R1',SenderINN__c='A1A1A1A1A1',SourceBrunch__c=branch.Id,
                    DestinationBrunch__c=branch.Id,Status__c='Received', System__c=systems.Id));
        // Sent payment from Recipient to Sender
        payments.add(new Payment__c(Amount__c=250, Date_send__c=system.now(), Sender__c='Recipient', Recipient__c='Sender', 
                     Type_of_transaction__c='Cash',RecepientINN__c='A1A1A1A1A1',SenderINN__c='R1R1R1R1R1',SourceBrunch__c=branch.Id,
                    DestinationBrunch__c=branch.Id,Status__c='Sent', System__c=systems.Id));
        
        insert payments; 
    }
    @isTest
	static void myTestGetSetPropertiesMethod() {
		
        Contact cont = [SELECT Id, INN__c, LastName FROM Contact WHERE INN__c = 'A1A1A1A1A1'];
        Contact reCont = [SELECT Id, INN__c, LastName FROM Contact WHERE INN__c = 'R1R1R1R1R1'];
		System__c systems = [SELECT Id, Name FROM System__c WHERE Name = 'MoneyGram'];
        

        //PageReference pageRef = Page.SendAndReceiveForm; 
        //pageRef.getParameters().put('id', cont.Id);
        //test.setCurrentPage(page);
        
        Apexpages.StandardController sc = new Apexpages.standardController(cont);
        controller = new SendAndReceiveFormController(sc);
       
        controller.recipientName = reCont.LastName;
        controller.amount = 1000;
        controller.recipientINN = 'R1R1R1R1R1';
        controller.type = 'Cash';
        controller.paymentSystem = systems.Id;
        controller.createPayment();
        
        List<SelectOption> selOptTypes = controller.getTypes();
        List<SelectOption> selOptPaymentStatuses = controller.getPaymentStatuses();
        List<SelectOption> selOptSystems = controller.getSystems();
        
        System.assertEquals(null,controller.sendPayment());
        
        Apexpages.StandardController sc1 = new Apexpages.standardController(reCont);
        controller = new SendAndReceiveFormController(sc1);

    }
    @isTest
    static void testMethodForPayMarkedItems() {
        
        Contact cont = [SELECT Id, INN__c, LastName FROM Contact WHERE INN__c = 'A1A1A1A1A1'];
        Contact reCont = [SELECT Id, INN__c, LastName FROM Contact WHERE INN__c = 'R1R1R1R1R1'];

        
        Apexpages.StandardController sc3 = new Apexpages.standardController(cont);
        controller = new SendAndReceiveFormController(sc3);
        
        controller.inboundPayments[0].status = 'Received';
        
		controller.payMarkedItems();
        
    }
        @isTest
    	static void testMethodSendPaymentWithNegativeAmount() {
        
        Contact cont = [SELECT Id, INN__c, LastName FROM Contact WHERE INN__c = 'A1A1A1A1A1'];
        Contact reCont = [SELECT Id, INN__c, LastName FROM Contact WHERE INN__c = 'R1R1R1R1R1'];
		System__c systems = [SELECT Id, Name FROM System__c WHERE Name = 'MoneyGram'];
            
        Apexpages.StandardController sc = new Apexpages.standardController(cont);
        controller = new SendAndReceiveFormController(sc);
        
        controller.createPayment();

        controller.recipientName = reCont.LastName;
        controller.amount = -450;
        controller.recipientINN = 'R1R1R1R1R1';
        controller.type = 'Cash';
        controller.paymentSystem = systems.Id;
            
        try{
       		controller.sendPayment();
        } catch(Exception ex){
			system.assert(ex.getMessage().contains('Amount cannot be less than 0'));
        }
    }
    
    @isTest
    static void testMethodGenerateRandomString() {
        
		String actual = 'qwertyuiop';
		String expected = PaymentService.generateRandomString(10);

		system.assert(expected.length() == actual.length());		        
    }
    


}