public with sharing class InfoAboutBranchesAndPaymentsController {

    public Bank__c currentBank{get;set;}
    public List<PaymentsWrapper> wrappers{get;set;}


    private Id currentBankId;

  
    public InfoAboutBranchesAndPaymentsController(ApexPages.StandardController controller) {
        
        currentBankId = controller.getRecord().Id;
        currentBank = getCurrentBankRecord();
        wrappers = new List<PaymentsWrapper>();
        fillWrappers();
    }

    private Bank__c getCurrentBankRecord(){
        return [SELECT Name FROM Bank__c WHERE Id = :currentBankId];        
    }

    public PageReference saveThisShit(){
        List<Brunch__c> branchesToUpdate = new List<Brunch__c>();
        for(PaymentsWrapper wrap : wrappers){
            branchesToUpdate.add(wrap.branch);
        }
        update branchesToUpdate;
        return null;
    }

    private Map<Id,Decimal> getSums(List<Brunch__c> branches){
        List<Id> branchIds = new List<Id>();
        for(Brunch__c br : branches){
            branchIds.add(br.Id);
        }
        return calculatePaymentSums(branchIds);
    }

    private Map<Id,Decimal> calculatePaymentSums(List<Id> brunchIds){
        AggregateResult[] groupedResults = [SELECT SUM(Amount__c), SourceBrunch__c, Status__c FROM Payment__c GROUP BY SourceBrunch__c, Status__c HAVING SourceBrunch__c IN :brunchIds AND Status__c = 'Received'];
        Map<Id,Decimal> sumsToReturn = new Map<Id,Decimal>();
        for(AggregateResult result : groupedResults){
            sumsToReturn.put((Id)result.get('SourceBrunch__c'), (Decimal)result.get('expr0') != null ? (Decimal)result.get('expr0') : 0.00);
        }
        return sumsToReturn;
    }

    private void fillWrappers(){
        List<Brunch__c> branches = [SELECT Id, Name, Coffers__c, (SELECT Name, Amount__c, Status__c FROM Payments__r WHERE Status__c = 'Received') FROM Brunch__c WHERE ParentBank__c = :currentBankId];
        Map<Id,Decimal> sumsInBranchesMap = getSums(branches);
        system.debug(sumsInBranchesMap);
        for(Brunch__c br : branches){
            system.debug(sumsInBranchesMap.get(br.Id));
            PaymentsWrapper wrap = new PaymentsWrapper();
            wrap.branch = br;
            wrap.sumOfPayments = sumsInBranchesMap.get(br.Id);
            wrappers.add(wrap);
        }
    }

    public class PaymentsWrapper{
        public Brunch__c branch{get;set;}
        public Decimal sumOfPayments{get;set;}
    }

}