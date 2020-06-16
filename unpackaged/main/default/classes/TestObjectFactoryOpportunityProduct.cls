public class TestObjectFactoryOpportunityProduct extends TestObjectFactory{
	
	public override Schema.SObjectType getSObjectType(){
        return OpportunityLineItem.SObjectType;
    }

    public override String getSObjectAPIName() {
        return 'OpportunityLineItem';
    }

    public OpportunityLineItem createRecord(Boolean doInsert){
        return (OpportunityLineItem) createObject(doInsert);
    }

    public void updateRecord(sObject record){
        updateObject(record);
    }
    public OpportunityLineItem updateRecord(sObject record, Boolean doInsert){
       return (OpportunityLineItem) updateObject(record, doInsert);
    }
    public SObject upsertRecord(sObject record){
        return (OpportunityLineItem) upsertObject(record);
    }

    public void deleteRecord(sObject record)
    {
    	deleteObject(record);
    }


}