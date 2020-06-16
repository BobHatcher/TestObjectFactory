public class TestObjectFactoryContract extends TestObjectFactory{

        public override Schema.SObjectType getSObjectType(){
            return Contract.SObjectType;
        }

        public override String getSObjectAPIName(){
            return 'Contract';
        }


        public Contract createRecord(Boolean doInsert){
            return (Contract) createObject(doInsert);
        }

        public void updateRecord(sObject record){
            updateObject(record);
        }

        public Contract updateRecord(sObject record, Boolean doInsert){
            return (Contract) updateObject(record, doInsert);
        }

        public SObject upsertRecord(sObject record){
            return (Contract) upsertObject(record);
        }

        public void deleteRecord(sObject record)
        {
            deleteObject(record);
        }


}