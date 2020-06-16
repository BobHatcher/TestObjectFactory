public with sharing class TestObjectFactoryOpportunity extends TestObjectFactory {

    public override Schema.SObjectType getSObjectType(){
        return Opportunity.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'Opportunity';
    }

    public Opportunity createRecord(Boolean doInsert){
        return (Opportunity) createObject(doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }
    public Opportunity updateRecord(sObject record, Boolean doInsert){
        return (Opportunity) updateObject(record, doInsert);
    }
    public SObject upsertRecord(sObject record){
        return (Opportunity) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }
}