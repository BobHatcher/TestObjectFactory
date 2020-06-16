public class TestObjectFactoryContact extends TestObjectFactory{

    public override Schema.SObjectType getSObjectType(){
        return Contact.SObjectType;
    }

    public Contact createRecord(Boolean doInsert){
        return (Contact) createObject(doInsert);
    }

    public override String getSObjectAPIName(){
        return 'Contact';
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public Contact updateRecord(sObject record, Boolean doInsert){
        return (Contact) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (Contact) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }

}