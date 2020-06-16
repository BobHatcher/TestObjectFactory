/**
 * Created by bhatcher on 6/10/20.
 */

global with sharing class FlowLookup {

    /*
    ** 10 June 2020 Bob Hatcher
    *
    * See http://www.stupidcrmtricks.com/2020/06/custom-lookup-for-flows-to-avoid.html for usage
    *
    * This is designed to be a generic Flow plugin that will execute an arbitrary lookup.
    * It can be used to get a field value, or an entire record. It uses helper classes FlowLookupRequest and FlowLookupResult.
    *
    * To work with Flow, the process must use a very awkward List<List<Object>> for input/output. For this purpose the
    * each OUTER list will contain a List with ONE item. In other words, if you are processing 3 records, you will get
    * 3 OUTER lists each with a List containing just one object.
    *
    * If your request specifies a resultField, the system will pull that field specifically, map it to a Flow compatible
    * type, and return it. If resultField is null it will return the entire object.
    *
    * Design Assumptions
    * - Each request can have different input field values
    * - Each request can have different input fields (columns)
    * - All requests in the transaction have the same returned field
    * - Data in the table will return zero or one results for a given combination of input fields
    * - All requests in a transaction request an Object or a Field. No mixing.
    * - Lookup table has a column called "Is_Test__c" (checkbox). The table should have a few records used exclusively for testing.
     */

    public static final Map<String,String> apexToFlow = new Map<String, String>{
            'blob' => 'invalid',
            'boolean' => 'boolean',
            'datetime' => 'datetime',
            'decimal' => 'currency',
            'double' => 'number',
            'email' => 'string',
            'id' => 'invalid',
            'integer' => 'number',
            'object' => 'invalid',
            'picklist' => 'string',
            'string' => 'string',
            'time' => 'invalid'
    };

    @InvocableMethod(label='Lookup a Value' description='Fires a generic lookup. See KB #16201')
    //https://salesforce.stackexchange.com/questions/76787/flow-invocablemethod-how-to-assign-output-to-collection-sobject-collection-v
    // must take and return a list of lists. Flow will bomb if the size of the request is not equal to that of the response.
    public static List <List<FlowLookupResult>> execute (List<List<FlowLookupRequest>> requestList) {
        System.debug('Begin Flow Lookup Plugin, requests qty ' + requestList.size());
        // inner list comes in with OUTER size = n with ONE item in each list.
        List<FlowLookupRequest> allRequests = new List<FlowLookupRequest>();
        for (List<FlowLookupRequest> innerList : requestList){
            allRequests.add(innerList[0]);
        }
        FlowLookupConfig config = null;
        try {
            config = new FlowLookupConfig(allRequests);
        } catch (Exception e){
            throw new MyException(e.getMessage());
        }
        try {
            List<List<FlowLookupResult>> results = findMatches(config, allRequests);
            if (results.size() != allRequests.size()){
                System.debug(LoggingLevel.ERROR,'********** FlowLookup Apex Class - got ' + results.size() + ' from ' + allRequests.size() + ' Requests. This is likely to cause the Flow to fail.');
            }
            return results;
        } catch (Exception e){
            throw new MyException(e.getMessage());
        }
    }

    public static Boolean validateRequest(FlowLookupRequest req){
        if (req.fieldNames == null || req.fieldNames.size() == 0){
            throw new MyException ('You need to specify at least one value in the FieldNames parameter.');
        }
        if (req.fieldValues == null || req.fieldValues.size() == 0){
            throw new MyException ('You need to specify at least one value in the fieldValues parameter.');
        }
        if (req.tableName == null || req.tableName.length() == 0){
            throw new MyException ('You need to specify a table name in the tableName parameter.');
        }
        return true;
    }

    public static List<String> getAllQueryFields(List<FlowLookupRequest> requests){
        Set<String> fields = new Set<String>(); // Set deduplicates

        for (FlowLookupRequest req : requests){
            if (req.fieldnames == null || req.fieldnames.size() == 0)
                throw new MyException('Request does not have any field names to check. Please set req.fieldNames.');
            fields.addAll(req.fieldNames);
        }
        return new List<String>(fields);
    }

    public static List<List<FlowLookupResult>> findMatches(FlowLookupConfig config, List<FlowLookupRequest> requests){
        List<sObject> results = config.results;
        List<List<FlowLookupResult>> toReturn = new List<List<FlowLookupResult>>();

        // Assembles a "key" which is the request fields concatenated together, then looks for a match in the
        // query results.

        for (FlowLookupRequest req : requests){
            String requestKey = String.join(req.fieldValues,'');
            Boolean foundResult = false;
            for (sObject obj : results){
                // go over each field and assemble a key that is the indicated fields mashed together.
                // this is compared against the one specified by the user
                String recordKey = '';
                for (Integer y = 0; y < req.fieldNames.size() ; y ++){
                    if (obj.get(String.valueOf(req.fieldNames[y])) != null)
                        recordKey += obj.get(String.valueOf(req.fieldNames[y]));
                }
                if (requestKey.toLowerCase() == recordKey.toLowerCase()){
                    System.debug('Found Matching Record with Key ' + requestKey.toLowerCase() );
                    toReturn.add(buildResponse(obj,config, req.recordId));
                    foundResult = true;
                }
            }
            if (!foundResult) { // want to return an empty container as a result if there is no result, since input and output sizes need to be the same.
                system.debug(('Result was not found for key '+requestKey+', adding an empty container.'));
                toReturn.add(new List<FlowLookupResult>{
                        new FlowLookupResult(req.recordId)
                });
            }
        }
        //for (List<FlowLookupResult> res : toReturn){
        //    System.debug('Got Result ' +printResultObject(res[0]));
        //}
        return toReturn;
    }

    public static List<FlowLookupResult> buildResponse(sObject obj, FlowLookupConfig config, Id rId){
        // this is instantiated from FindMatch... if this comes through this way there is a matching record.
        FlowLookupResult res = new FlowLookupResult();
        res.hasResult = false;
        res.recordId = rId;
        if (config.instruction == 'record' && obj != null){ // to be safe
            res.resultRecord = obj;
            res.hasResult = true;
        } else {
            Object fieldValue = obj.get(config.resultField);
            if (fieldValue == null){
                res.hasResult = false;
            } else {
                res.hasResult = true;
                String apexType = FlowLookup.getResultFieldType(config.tableName,config.resultField);

                if (apexToFlow.get(apexType) == 'boolean'){
                    res.resultBoolean = (Boolean) fieldValue;
                } else if (apexToFlow.get(apexType) == 'datetime'){
                    res.resultDateTime = (DateTime) fieldValue;
                } else if (apexToFlow.get(apexType) == 'decimal'){
                    res.resultDecimal = (Decimal) fieldValue;
                } else if (apexToFlow.get(apexType) == 'string'){
                    res.resultText = (String) fieldValue;
                } else if (apexToFlow.get(apexType) == 'date'){
                    res.resultDate = (Date) fieldValue;
                } else if (apexToFlow.get(apexType) == 'number') {
                    res.resultNumber = (Double) fieldValue;
                } else {
                    throw new MyException('Flow Error: Apex type ' + apexType + ' is not supported in Flow.');
                }
            }
        }
        return new List<FlowLookupResult>{res};
    }

    public class FlowLookupConfig {

        // The Config object holds the information about the requests.

        public String Instruction {get;set;}
        public String TableName {get;set;}
        public String WhereClause {get;set;}
        public String Query {get;set;}
        public String ResultField {get;set;}
        public List<sObject> Results {get;set;}
        public List<String> AllFieldNames{get;set;}
        public Integer iterator {get;set;}

        public FlowLookupConfig(List<FlowLookupRequest> requests){
            System.debug('** FlowLookupConfig Begin, requests ' + requests.size());
            AllFieldNames = getAllQueryFields(requests);
            WhereClause = '';
            Iterator = 0;

            // Remove null values from the list, if any came in.
            requests = removeNulls(requests);
            for (FlowLookupRequest req : requests){
                System.debug('** FlowLookup: FlowLookupConfig: Request: ' + req);
                FlowLookup.validateRequest(req);
            }

            // Variables assumed to be the same for all requests in the transaction
            Instruction = (requests[0].resultField == null ? 'record' : 'field');
            TableName = requests[0].TableName; // assume they are all in the same table
            WhereClause = (requests[0].WhereClause == null || requests[0].whereClause.length() == 0 ? '' : ' AND (' + requests[0].WhereClause + ')');

            List<String> notNull = new List<String>();
            if (AllFieldNames != null && AllFieldNames.size() > 0){
                for (String f : AllFieldNames){
                    notNull.add(' ' + f + ' != null ');
                }
            }

            ResultField = (Instruction == 'field' ? requests[0].resultField : '');
            Boolean isTest = Test.IsRunningTest();
            Query = 'SELECT ' + String.join(AllFieldNames,',') + (Instruction == 'field' ? ',' + ResultField : '') + ' FROM ' + TableName + ' WHERE (' + String.join(notNull,' AND ') + ') ' + WhereClause ;
            // Lookup tables should have "Is_Test__c" column to indicate if the record is a test record
            // Check if the column is there and if so add it.
            SObjectType accountType = Schema.getGlobalDescribe().get(tableName);
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            Query += (mFields.containsKey('Is_Test__c') ? ' AND Is_Test__c = '+ isTest : '' );
            Results = database.query(Query);
        }
    }



    public static String getResultFieldType(String tableName, String resultField){
        // Determine the type of the result field. Don't use this for "record" requests.
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType ctype = gd.get(tableName);
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();
        return String.valueOf(fmap.get(resultField).getDescribe().getType()).toLowerCase();
    }



    public static List<FlowLookupRequest> removeNulls(List<FlowLookupRequest> requests){
        Integer j = 0;
        while (j < requests.size())
        {
            if(requests == null)
            {
                requests.remove(j);
            }else
            {
                j++;
            }
        }
        return requests;
    }

    //** toString methods for debugging **/
/*
    public static String printRequestObject(FlowLookupRequest req){
        String out = '\n** FlowLookupRequest\n';
        out += '  - fieldNames : ' + req.fieldNames + '\n';
        out += '  - fieldValues : ' + req.fieldValues + '\n';
        out += '  - tableName : ' + req.tableName + '\n';
        out += '  - whereClause : ' + req.whereClause + '\n';
        out += '  - resultField : ' + req.resultField + '\n';
        out += '  - recordId : ' + req.recordId + '\n';
        return out;
    }


    public static String printRequests(List<List<FlowLookupRequest>> listOfLists){
        Integer outerNodeIndex = 0;

        String out = '\n\n******Request Lists';
        for (List<FlowLookupRequest> outerList : listOfLists){
            out += '\n-----------------------\n-- Outer Node ' + outerNodeIndex + '\n';
            Integer innerNodeIndex = 0;
            for (FlowLookupRequest req : outerList){
                out += '  - Inner Node : ' + outerNodeIndex + '-' + innerNodeIndex + '\n';
                out += printRequestObject(req);
                innerNodeIndex ++;
            }
            outerNodeIndex ++;
        }
        return out;
    }
*/

    public static String printResultObject(FlowLookupResult res){
        String out = '\n** FlowLookupResult\n';
        out += '  - hasResult : ' + res.hasResult + '\n';
        out += '  - resultText : ' + res.resultText + '\n';
        out += '  - resultBoolean : ' + res.resultBoolean + '\n';
        out += '  - resultDecimal : ' + res.resultDecimal + '\n';
        out += '  - resultNumber : ' + res.resultNumber + '\n';
        out += '  - resultDate : ' + res.resultDate + '\n';
        out += '  - resultDateTime : ' + res.resultDateTime + '\n';
        out += '  - recordId : ' + res.recordId + '\n';
        out += '  - resultRecord : ' + (res.resultrecord == null ? 'Null' : res.resultRecord.Id) + '\n';
        return out;
    }

}