public class TestObjectFactoryAccount extends TestObjectFactory {

    public override Schema.SObjectType getSObjectType(){
        return Account.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'Account';
    }

    public Account createRecord(Boolean doInsert){
        return (Account) createObject( doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public Account updateRecord(sObject record, Boolean doInsert){
        return (Account) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (Account) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }

}