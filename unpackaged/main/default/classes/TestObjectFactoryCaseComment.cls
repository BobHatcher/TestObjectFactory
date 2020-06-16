public class TestObjectFactoryCaseComment extends TestObjectFactory{


    public override Schema.SObjectType getSObjectType(){
        return CaseComment.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'CaseComment';
    }

    public CaseComment createRecord(Boolean doInsert){
        return (CaseComment) createObject( doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public CaseComment updateRecord(sObject record, Boolean doInsert){
        return (CaseComment) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (CaseComment) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }

}