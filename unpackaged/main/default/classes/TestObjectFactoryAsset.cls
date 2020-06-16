public class TestObjectFactoryAsset extends TestObjectFactory {
	
	public override Schema.SObjectType getSObjectType(){
        return Asset.SObjectType;
    }


    public Asset createRecord(Boolean doInsert){
        return (Asset) createObject(doInsert);
    } 

    public override String getSObjectAPIName(){
        return 'Asset';
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public Asset updateRecord(sObject record, Boolean doInsert){
        return (Asset) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (Asset) upsertObject(record);
    }

    public void deleteRecord(sObject record){
        deleteObject(record);
    }

}