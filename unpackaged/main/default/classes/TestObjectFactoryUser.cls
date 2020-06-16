public with sharing class TestObjectFactoryUser extends TestObjectFactory {
    public static final String ERROR_MSG_ON_DELETE = 'Fatal: TestObjectFactoryUser: Can Not Delete User';

    public override Schema.SObjectType getSObjectType(){
        return User.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'User';
    }

    public User createRecord(Boolean doInsert){
        return (User) createObject( doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public User updateRecord(sObject record, Boolean doInsert){
        return (User) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (User) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        throw new MyException(ERROR_MSG_ON_DELETE);
    }
}