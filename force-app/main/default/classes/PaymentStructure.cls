public with sharing class PaymentStructure {
    public PaymentStructure(){}
    public Decimal amount;
    public Id sourceBranch;
    public Id destinationBranch;
    public Datetime dateSend;
    public Datetime datePayOut;
    public String senderName;
    public String recipientName;
    public Id paymentSystem;
    public String type;
    public String paymentStatus;
    public Id paymentId;
    public String recipientINN;
    public String senderINN;
    
}