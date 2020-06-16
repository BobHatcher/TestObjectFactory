public class TestObjectFactoryPricebook2 extends TestObjectFactory{


public override Schema.SObjectType getSObjectType(){
return Pricebook2.SObjectType;
}

public override String getSObjectAPIName() {
return 'Pricebook2';
}

public Pricebook2 createRecord(Boolean doInsert){
return (Pricebook2) createObject( doInsert);
}

public void updateRecord(sObject record){
updateObject(record);
}
public Pricebook2 updateRecord(sObject record, Boolean doInsert){
return (Pricebook2) updateObject(record, doInsert);
}
public SObject upsertRecord(sObject record){
return (Pricebook2) upsertObject(record);
}

public void deleteRecord(sObject record)
{
deleteObject(record);
}


}