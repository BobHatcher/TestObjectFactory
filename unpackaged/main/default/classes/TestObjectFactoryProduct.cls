public class TestObjectFactoryProduct extends TestObjectFactory {
	
	public override Schema.SObjectType getSObjectType(){
        return Product2.SObjectType;
    }

    public Product2 createRecord(Boolean doInsert){
        return (Product2) createObject(doInsert);
    } 

    public override String getSObjectAPIName(){
        return 'Product2';
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }

    public Product2 updateRecord(sObject record, Boolean doInsert){
        return (Product2) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record){
        return (Product2) upsertObject(record);
    }

    public void deleteRecord(sObject record){
        deleteObject(record);
    }

}