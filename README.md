# TestObjectFactory
A pattern that can be used to generate test data with default values.

See TestObjectFactoryExample.cls for usage examples.

## To Install
You can copy the code straight out of GitHub; you will need TestObjectFactory at a minimum. 
- Error handlers and utility classes are provided.
- Factory classes for common standard objects are provided.
- You will need to create a Custom Metadata table called `Test_Class_Default__mdt` with the following fields:
  - Checkbox_Value__c - Checkbox
  - DateTime_Value__c - DateTime
  - Date_Value__c - Date
  - Email_Value__c - Email
  - Lookup_Value__c
  - Lookup_Object__c
  - Lookup_Field__c
  - Number_Value__c - Number
  - Percent_Value__c - Percent
  - Phone_Value__c - Phone
  - Picklist_Value__c - Picklist
  - Text_Area_Value__c - TextArea
  - Text_Value__c - Text (255)
  - URL_Value__c - URL
  - Field__c - Text (80)
  - Type__c - Picklist (values: 'Checkbox', ' DateTime', ' Date', 'Email', 'Number', 'Percent', 'Phone', 'Picklist', 'Text Area', 'Text', 'URL')
  - Is_Test__c
  
`TestObjectFactoryTest` contains values for all included objects. If you choose not to add those files, you will need to remove the corresponding methods from that file.
  
### To Create a Default Value
Simply create a custom metadata record and set the following:
- Field = API Name of the field you want to populate (e.g., Custom_Field__c)
- Object = API Name of the object you want to populate (e.g., Custom_Object__c)
- Is Test = false

Depending on the type of the defaulted field, set the Type and the Value field accordingly. For example, to set Name on Account, set:
- Type = Text
- Text Value = 'Your Default Value'

The DeveloperName of your custom metadata record doesn't have any requirements other than being unique.

Once you create the metadata, you'll never have to bother with a default value in your test code again!

### Default Value Special Cases

#### Picklists
Although picklists have their own type in the code, you can treat them as text.

#### Record Types
For record types, set the Field to `RecordTypeId` and the Text Value to the name of the Record Type.

#### Users
Users have a lot of wonky rules, and this method is definitely not immune to the dreaded `MIXED_DML_OPERATION` error. If you need to generate Users, `TestObjectUtilities` has a method called generateUsers(), which we recommend using as a shortcut.

#### Lookup Fields
In test code you're not defaulting lookups since the record ID's are different in every org. But this process will allow you to default a value and it will look it up on the fly.

Lookups require you to fill out three fields for its value:
- Lookup Object: The object that the Lookup should check against. For example, if setting the AccountId on Contact, specify: Account
- Lookup Value: Value to Lookup (using Name field)
- Lookup Field: Field to lookup against in the destination object

For example, if you want the default AccountId of a Contact to be the Account called "Test Account", you would set the Lookup Object to Account, the Lookup Value to "Test Account" and the Lookup Field to "Name". When you construct your Contact, the system will go find that Account and populate it.

#### Is Test
Metadata values used for testing _the process itself_ should be tagged with Is_Test__c. In `TestObjectFactoryTest` the `Defaults()` method expects a Lookup value with a DeveloperName = `Contact_Parent_For_Test`.

## To Create a Factory for a New Object
For example, to create a TestObjectFactory for Custom_Object__c:
1. Create a file called TestObjectFactoryCustomObject
1. Take one of the other factory files, like the one for "Lead", then replace all instances of "Lead" with "Custom_Object__c"
   1. Make sure the class extends TestObjectFactory.
1. Create a test method in TestObjectFactory for the TestObjectFactoryCustomObject. To start, you can copy an existing one, such as TestObjectFactoryAttachment, and follow the setup instructions in the comments of the method. 

## Performance and Governor Limit Considerations
Despite being a good bit of code, this process is quite lightweight at runtime. It will fire only one query per transaction. All values are pulled and cached in memory. Salesforce allows unlimited metadata queries in governor limits.
