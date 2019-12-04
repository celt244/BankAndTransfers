@isTest
public with sharing class TestPaymentTriggerHelper {

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

        List<Payment__c> payments = new List<Payment__c>();
        payments.add(new Payment__c(Amount__c=200, Type_of_transaction__c='Cash', SourceBrunch__c=branch.Id, DestinationBrunch__c=branch.Id,Status__c=PaymentStatuses.SENT, System__c=systems.Id));
        payments.add(new Payment__c(Amount__c=300, Type_of_transaction__c='Cash', SourceBrunch__c=branch.Id, DestinationBrunch__c=branch.Id,Status__c=PaymentStatuses.CREATED, System__c=systems.Id));
        insert payments;

    }

    @isTest
    static void testDecreaseDestinationBranchCoffersWhenPaymentReceivedWithCash(){

        //given
        List<Payment__c> payments = [SELECT Amount__c, Type_of_transaction__c, SourceBrunch__c, DestinationBrunch__c, Status__c, System__c
                                    FROM Payment__c WHERE Status__c = :PaymentStatuses.SENT];
        Brunch__c branch = [SELECT Id,Name,Coffers__c FROM Brunch__c WHERE Name='First'];
        Decimal expected = branch.Coffers__c - 200;
        System.debug(expected);

        //when
        payments[0].Status__c = PaymentStatuses.RECEIVED;
        update payments;

        Brunch__c updateBranch = [SELECT Id,Name,Coffers__c FROM Brunch__c WHERE Name='First'];
        Decimal actual = updateBranch.Coffers__c;
        System.debug(actual);

        //then
        System.assertEquals(expected, actual);
    }

    @isTest
    static void testIncreaseSourceBranchCoffersWhenPaymentSentWithCash(){

        //given
        List<Payment__c> payments = [SELECT Amount__c, Type_of_transaction__c, SourceBrunch__c, DestinationBrunch__c, Status__c
                                    FROM Payment__c WHERE Status__c = :PaymentStatuses.CREATED];
        Brunch__c branch = [SELECT Id,Name,Coffers__c FROM Brunch__c WHERE Name='First'];
        Decimal expected = branch.Coffers__c + 300;
        System.debug(expected);
        
        //when
        payments[0].Status__c = PaymentStatuses.SENT;
        update payments;

        Brunch__c updateBranch = [SELECT Id,Name,Coffers__c FROM Brunch__c WHERE Name='First'];
        Decimal actual = updateBranch.Coffers__c;
        System.debug(actual);

        //then
        System.assertEquals(expected, actual);
    }
}