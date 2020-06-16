/**
 * Created by bhatcher on 6/16/20.
 */

public with sharing class FlowLookupRequest {
    public FlowLookupRequest(){}
    @AuraEnabled
    @InvocableVariable(label='Field API Names' description='Enter a list of fields to query.' required=true)
    public List<String> fieldNames;
    @AuraEnabled
    @InvocableVariable(label='Query Values' description='Enter the values to Query. must be in the smae order as the field list.' required=true)
    public List<String> fieldValues;
    @AuraEnabled
    @InvocableVariable(label='Table Name' description='API name of the table/object to query.' required=true)
    public String tableName;
    @AuraEnabled
    @InvocableVariable(label='Where Clause' description='Additional where clause. Will run with AND. Do NOT include the word "where".' required=false)
    public String whereClause;
    @AuraEnabled
    @InvocableVariable(label='Result Field' description='If you want a specific field returned, enter its API name here. If you leave this blank, it will return the entire Object that matches your criteria.' required=false)
    public String resultField;
    @AuraEnabled
    @InvocableVariable(label='Record ID' description='The Record ID that this Lookup will apply to; for use later in the Flow.' required=true)
    public String recordId;
}