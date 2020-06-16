public with sharing class TestObjectFactoryOpportunityContactRole extends TestObjectFactory{
    public override Schema.SObjectType getSObjectType(){
        return OpportunityContactRole.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'OpportunityContactRole';
    }

    public OpportunityContactRole createRecord(Boolean doInsert){
        return (OpportunityContactRole) createObject(doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }
    public OpportunityContactRole updateRecord(sObject record, Boolean doInsert){
        return (OpportunityContactRole) updateObject(record, doInsert);
    }
    public SObject upsertRecord(sObject record){
        return (OpportunityContactRole) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }
}