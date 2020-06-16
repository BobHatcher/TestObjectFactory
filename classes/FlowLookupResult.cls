

global with sharing class FlowLookupResult {

    // See limitations on what can be done with this type.
    // https://help.salesforce.com/articleView?id=flow_considerations_apex_data_type.htm&type=5

    public FlowLookupResult(){
        hasResult=false;
    }

    public FlowLookupResult(Id rId){
        hasResult=false;
        recordId = rId;
    }

    // Result will return EITHER a resultRecord OR one of the other variables based on the type.
    // To get a record, in the request, set resultField = null.

    // For example, if your result field is an integer field, the result value will come back in resultNumber.

    @InvocableVariable(label='Result - Record' description='If you asked for the process to return a record, it is returned in this variable.' required=false)
    @AuraEnabled
    public sObject resultRecord;
    @InvocableVariable(label='Result - Text' description='If you asked for the process to return text, it will be returned in this variable. If you need a picklist, use this.' required=false)
    @AuraEnabled
    public String resultText;
    @InvocableVariable(label='Result - Boolean' description='If you asked for the process to return boolean, it will be returned in this variable.' required=false)
    @AuraEnabled
    public Boolean resultBoolean;
    @InvocableVariable(label='Result - Currency' description='If you asked for the process to return Currency (decimal), it will be returned in this variable.' required=false)
    @AuraEnabled
    public Decimal resultDecimal;
    @InvocableVariable(label='Result - Number' description='If you asked for the process to return a number (integer or float), it will be returned in this variable.' required=false)
    @AuraEnabled
    public Decimal resultNumber;
    @InvocableVariable(label='Result - Date' description='If you asked for the process to return a Date, it will be returned in this variable.' required=false)
    @AuraEnabled
    public Date resultDate;
    @InvocableVariable(label='Result - DateTime' description='If you asked for the process to return a DateTime, it will be returned in this variable.' required=false)
    @AuraEnabled
    public DateTime resultDateTime;
    @InvocableVariable(label='Has Result' description='Boolean value indicates whether there is a value in this Result' required=false)
    @AuraEnabled
    public Boolean hasResult ;
    @InvocableVariable(label='Record ID' description='The ID of the original record associated to this result value.' required=false)
    @AuraEnabled
    public Id recordId ;
}