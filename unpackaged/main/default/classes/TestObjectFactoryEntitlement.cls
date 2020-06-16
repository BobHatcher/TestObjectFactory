public with sharing class TestObjectFactoryEntitlement extends TestObjectFactory {

    public override Schema.SObjectType getSObjectType(){
        return Entitlement.SObjectType;
    }

    public override String getSObjectAPIName(){
        return 'Entitlement';
    }


    public Entitlement createRecord(Boolean doInsert){
        return (Entitlement) createObject(doInsert);
    }


    public void updateRecord(sObject record){
        updateObject(record);
    }

    public Entitlement updateRecord(sObject record, Boolean doInsert){
        return (Entitlement) updateObject(record, doInsert);
    }
    public SObject upsertRecord(sObject record){
        return (Entitlement) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }
}