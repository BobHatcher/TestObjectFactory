public class TestObjectFactoryLead extends TestObjectFactory{


    public override Schema.SObjectType getSObjectType(){
        return Lead.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'Lead';
    }

    public Lead createRecord(Boolean doInsert){
        return (Lead) createObject( doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }
    public Lead updateRecord(sObject record, Boolean doInsert){
        return (Lead) updateObject(record, doInsert);
    }
    public SObject upsertRecord(sObject record){
        return (Lead) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }

}