public class TestObjectFactoryCampaign extends TestObjectFactory{

    public override Schema.SObjectType getSObjectType(){
        return Campaign.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'Campaign';
    }

    public Campaign createRecord(Boolean doInsert){
        return (Campaign) createObject( doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public Campaign updateRecord(sObject record, Boolean doInsert){
        return (Campaign) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (Campaign) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }

}