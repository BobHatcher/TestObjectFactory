/**
 * Created by bhatcher on 6/16/20.
 */

public abstract class TestObjectFactory {

    // 20 July 2017 R Hatcher
    // Based on https://salesforce.stackexchange.com/questions/83939/dynamic-casting-of-sobject-objects

    public abstract Schema.SObjectType getSObjectType();
    public abstract String getSObjectAPIName();
    List<Test_Class_Default__mdt> defaults = new List<Test_Class_Default__mdt>();
    private integer beforeQueryCount;
    private integer afterQueryCount;
    private integer netQueryCount;
    public Boolean useDefaults = true;
    public Boolean useValues = true;
    private sObject recordWithDefaults = null;
    private Map<SObjectField, object> allDefaults = new Map<SObjectField, object>();
    private Set<String> allUsers = new Set<String>();
    // Get all the fields from the Object as sObjectField records
    // Then set the sObjectField value as a plain Object

    private Set<sObjectField> suppressedDefaults = new Set<SobjectField>();
    private Map<SobjectField, Object> values = new Map<SobjectField, Object>();

    public Boolean restrictDefaultsToIsTest = false;

    public void setFieldValue(sObjectField field, Object value) {
        values.put(field, value);
    }

    public void suppressDefault(sObjectField field) {
        if (!suppressedDefaults.contains(field))
            suppressedDefaults.add(field);
    }

    public void removeFieldValue(sObjectField field) {
        if (values.containsKey(field))
            values.remove(field);
    }

    public void clearFieldValues() {
        values = new Map<SobjectField, Object>();
    }

    public Object getFieldValue(sObjectField field)
    {
        if (values.get(field) != null) {
            return values.get(field);
        }
        else {
            return null;
        }
    }

    public  String getValues() {
        return values.toString();
    }

    public SObject createObject(Boolean doInsert) {

        // If useValues == true, the system will apply the values in the values Map,
        // overriding defaults.

        // Initialize the object to return
        SObject record = this.getSObjectType().newSObject(null, true);

        // Fill defaults
        if (useDefaults)
            record = fillDefaults(record, false);



        // Populate the record with values passed to the method
        if (values != null && useValues)
            for (SObjectField eachField : values.keySet()) {
                //System.debug('** REH createRecord Creating Field ' + eachField);
                if (!suppressedDefaults.contains(eachField)) {
                    if (eachField != null) {
                        //System.debug('Setting ' + eachField + ' to ' + values.get(eachField));
                        record.put(eachField, values.get(eachField));
                    }
                } else {
                    System.debug('** REH Suppressed Default ' + eachField);
                }
            }

        // Special Handling for user
        // double check that the username isn't taken and if it is append a character to it
        if (this.getSObjectAPIName() == 'User')
        {
            if (allUsers.size() == 0)
            {
                List<User> users = [Select Username from User];
                for (User  u : users)
                    if (!allUsers.contains(u.username)) // shouldn't, but just in case
                        allUsers.add(u.username);
            }
            if (allUsers.contains(String.valueOf(record.get('username')))) {
                record.put(User.Username, 'X' + record.get('username'));
                allUsers.add('X' + record.get('username'));
                System.debug(LoggingLevel.WARN,'TestObjectFactory Found Duplicated Username, prepended an \'X\'');
            }
        }

        if (doInsert) {
            beforeQueryCount = Limits.getAggregateQueries();
            insert record;
            afterQueryCount = Limits.getAggregateQueries();
            logPerformance('createObject', 1);
        }
        // Return the record

        return record;
    }

    public void bulkInsert(List<sObject> insertList) {
        beforeQueryCount = Limits.getAggregateQueries();
        insert insertList;
        afterQueryCount = Limits.getAggregateQueries();
        logPerformance('bulkInsert', insertList.size());
    }

    public void updateObject(sObject record) {
        sObject discard = updateObject(record, true);

    }

    public sObject updateObject(sObject record, Boolean doUpdate) {
        if (record.Id == null )
            System.debug(LoggingLevel.WARN,'TestObjectFactory: Attempt to update object without an ID'); // can't throw a full error since in some cases the values object may be carrying the ID

        for (SObjectField eachField : values.keySet()) {
            if (eachField != null && values.get(eachField) != null) {
                record.put(eachField, values.get(eachField));
            }
        }

        if (doUpdate) {
            beforeQueryCount = Limits.getAggregateQueries();
            update record;
            afterQueryCount = Limits.getAggregateQueries();
            logPerformance('updateObject', 1);
        }
        return record;
    }

    public SObject upsertObject(sObject record) {
        for (SObjectField eachField : values.keySet()) {
            record.put(eachField, values.get(eachField));
        }

        beforeQueryCount = Limits.getAggregateQueries();
        upsert record;
        afterQueryCount = Limits.getAggregateQueries();
        logPerformance('upsertObject', 1);
        return record;

    }

    public void bulkUpdate(List<sObject> updateList) {
        beforeQueryCount = Limits.getAggregateQueries();
        update updateList;
        afterQueryCount = Limits.getAggregateQueries();
        logPerformance('bulkUpdate', updateList.size());
    }

    public void bulkUpsert(List<sObject> upsertList) {
        beforeQueryCount = Limits.getAggregateQueries();
        upsert upsertList;
        afterQueryCount = Limits.getAggregateQueries();
        logPerformance('bulkUpsert', upsertList.size());
    }

    public void deleteObject(sObject record) {
        String recordId = record.Id;

        beforeQueryCount = Limits.getAggregateQueries();
        database.delete(record);
        afterQueryCount = Limits.getAggregateQueries();
        logPerformance('deleteObject', 1);


    }


    public sObject fillDefaults(sObject record, Boolean isTest) {

        // Public so TestObjectFactoryTest can see it.
        String objectName;
        if (isTest)
            objectName = 'TestObjectFactoryTest'; else
                objectName = getSObjectAPIName();
        SObjectType objectType = getSObjectType();
        String testName;
        String objectNameLowerCase = objectName.toLowerCase();

        Map<String, Schema.SObjectField> mFields = getSObjectType().getDescribe().fields.getMap();

        if (this.defaults.size() == 0) {
            this.defaults = [
                    SELECT
                            Checkbox_Value__c
                            ,DateTime_Value__c
                            ,Date_Value__c
                            ,Email_Value__c
                            ,Field__c
                            ,Number_Value__c
                            ,Percent_Value__c
                            ,Phone_Value__c
                            ,Picklist_Value__c
                            ,Text_Area_Value__c
                            ,Text_Value__c
                            ,Type__c
                            ,URL_Value__c
                            ,Lookup_Value__c
                            ,Lookup_Object__c
                            ,Lookup_Field__c
                            ,Is_Test__c
                    FROM Test_Class_Default__mdt
                    WHERE (Object__c = :objectName OR Object__c = : objectNameLowerCase)
                    AND Field__c != null
                    AND Is_Test__c = :this.restrictDefaultsToIsTest
            ];

        }

        for (Test_Class_Default__mdt d : this.defaults) {
            if (allDefaults.containsKey(mFields.get(d.Field__c.toLowerCase())) && allDefaults.get(mFields.get(d.Field__c.toLowerCase())) != null) {
                record.put(mFields.get(d.Field__c.toLowerCase()), allDefaults.get(mFields.get(d.Field__c.toLowerCase())));
            } else {
                Object value = null;
                if (d.Type__c == 'Checkbox')
                    value = d.Checkbox_Value__c;
                if (d.Type__c == 'Date')
                    value = d.Date_Value__c;
                if (d.Type__c == 'DateTime')
                    value = d.DateTime_Value__c;
                if (d.Type__c == 'Email')
                    value = d.Email_Value__c;
                if (d.Type__c == 'Number')
                    value = d.Number_Value__c;
                if (d.Type__c == 'Percent')
                    value = d.Percent_Value__c;
                if (d.Type__c == 'Phone')
                    value = d.Phone_Value__c;
                if (d.Type__c == 'Picklist')
                    value = d.Picklist_Value__c;
                if (d.Type__c == 'Text')
                    value = d.Text_Value__c;
                if (d.Type__c == 'Text Area')
                    value = d.Text_Area_Value__c;
                if (d.Type__c == 'URL')
                    value = d.URL_Value__c;

                // RecordType needs to be unique because of the sObjectType filter. can't assume name won't be reused across objects.
                if (d.Field__c == 'RecordTypeId') {

                    value = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(d.Text_Value__c).getRecordTypeId();

                    if (value == null)
                        throw new MyException('Error setting default record type for ' + objectName + ' - Value ' + d.Text_Value__c + ' not found');
                }

                if (d.Type__c == 'Lookup') {

                    if (d.Lookup_Value__c == null || d.Lookup_Object__c == null || d.Lookup_Field__c == null)
                        throw new MyException('Error setting default record type for Lookup field ' + d.Lookup_Object__c + ' - Value ' + d.Lookup_Field__c + ' - can not set Lookup if one or more of the 3 Lookup fields is null.');
                    String query = 'SELECT Id from ' + d.Lookup_Object__c + ' Where ' + d.Lookup_Field__c + ' =  \'' + d.Lookup_Value__c + '\'';
                    System.debug('** REH Setting default Lookup; assembled query: ' + query);
                    List<sObject> lookupValues = Database.query(query);

                    if (lookupValues.size() <> 1)
                        throw new MyException('Error setting default record type for Lookup field ' + d.Lookup_Object__c + ' - Field ' + d.Lookup_Field__c + ' with value ' + d.Lookup_Value__c + ' not found or too many matches, size = ' + lookupValues.size());

                    value = (id) lookupValues[0].Id;

                }


                try {
                    if (value != null && !isTest) {
                        if (!suppressedDefaults.contains(mFields.get(d.Field__c.toLowerCase()))) {
                            record.put(mFields.get(d.Field__c.toLowerCase()), value);
                            allDefaults.put(mFields.get(d.Field__c.toLowerCase()), value);
                            //System.debug('TestObjectFactory: Creating Field: ' + d.Field__c + ' on Object ' + objectName + ' With Value: ' + value);
                        }
                    } else
                            testName = d.Text_Value__c;
                } catch (System.Exception e) {
                    String error = 'TestObjectFactory: Unable to set default field ' + d.Field__c + ' (' + mFields.get(d.Field__c.toLowerCase()) + ') to value ' + value + ' On Object ' + objectName + ' Error:' + e.getMessage();
                    System.debug(error);
                    throw new MyException(error);
                }
            }


        }


        if (isTest) {
            this.recordWithDefaults = new Account(Name = testName);
        } else {
            this.recordWithDefaults = record.clone();
        }
        return record;
    }

    private void logPerformance(String descriptor, Integer recordQuantity) {
        this.netQueryCount = this.afterQueryCount - this.beforeQueryCount;
        Integer runningQueryCount = GlobalUtilities.incrementQueryCount(this.netQueryCount);
        System.debug('#PerformanceLog: ' + descriptor + ' for ' + getSObjectAPIName() + ' Completed Operation on ' + recordQuantity + ' records and used ' + runningQueryCount + ' aggregate queries.');

    }

}