public class TestObjectFactoryFeedItem extends TestObjectFactory{

    public override Schema.SObjectType getSObjectType() {
        return FeedItem.SObjectType;
    }


    public FeedItem createRecord(Boolean doInsert) {
        return (FeedItem) createObject(doInsert);
    }

    public override String getSObjectAPIName() {
        return 'FeedItem';
    }

    public void updateRecord(sObject record) {
        updateObject(record);
    }

    public FeedItem updateRecord(sObject record, Boolean doInsert) {
        return (FeedItem) updateObject(record, doInsert);
    }

    public SObject upsertRecord(sObject record) {
        return (FeedItem) upsertObject(record);
    }

    public void deleteRecord(sObject record) {
        deleteObject(record);
    }

}