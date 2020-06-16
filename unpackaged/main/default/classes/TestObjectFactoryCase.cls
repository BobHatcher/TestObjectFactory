public class TestObjectFactoryCase extends TestObjectFactory{

    public override Schema.SObjectType getSObjectType(){
        return Case.SObjectType;
    }


    public Case createRecord(Boolean doInsert){
        return (Case) createObject(doInsert);
    }

    public override String getSObjectAPIName(){
        return 'Case';
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public Case updateRecord(sObject record, Boolean doInsert){
        return (Case) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (Case) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }

}