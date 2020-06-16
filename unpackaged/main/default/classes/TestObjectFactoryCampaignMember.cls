public class TestObjectFactoryCampaignMember extends TestObjectFactory{

    public override Schema.SObjectType getSObjectType(){
        return CampaignMember.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'CampaignMember';
    }

    public CampaignMember createRecord(Boolean doInsert){
        return (CampaignMember) createObject( doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public CampaignMember updateRecord(sObject record, Boolean doInsert){
        return (CampaignMember) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (CampaignMember) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
        deleteObject(record);
    }

}