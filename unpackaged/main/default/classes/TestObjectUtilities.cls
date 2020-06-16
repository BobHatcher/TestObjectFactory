public with sharing class TestObjectUtilities {

    public static Integer userCount = 0; // global counter to make sure usernames aren't duplicated

    public static Account createChildAccount(Id accountId, Boolean doInsert) {
        TestObjectFactoryAccount accountFactory = new TestObjectFactoryAccount();
        accountFactory.setFieldValue(Account.Name, 'Child Account');
        accountFactory.setFieldValue(Account.ParentId, accountId);
        return accountFactory.createRecord(doInsert);
    }

    public static Account getNewAccount() {
        TestObjectFactoryAccount factory = new TestObjectFactoryAccount();
        return factory.createRecord(true);
    }

    public static Contact getNewContact(Id accountId) {
        TestObjectFactoryContact factory = new TestObjectFactoryContact();
        factory.setFieldValue(Contact.AccountId, accountId);
        return factory.createRecord(true);
    }

    public static List<User> generateUsers(Integer quantity, String profile) {
        return generateUsers(quantity,profile,0);
    }

    public static List<User> generateUsers(Integer quantity, String profile, Integer usernameOffset) {
        // userCount will seed this at 1000, 2000, etc. each time it is called
        // first call will give users 1000, 1001, 1002 etc, 2nd call will give 2000, 2001, 2002
        TestObjectFactoryUser factory = new TestObjectFactoryUser();

        // when creating Community users under runAs() it's important that the running user have a Role.
        if (profile == GlobalUtilities.PROFILE_SALES_REP) {
            // no point in caching these queries since this will only be run once thanks to MIXED_DML
            factory.setFieldValue(User.UserRoleId, [SELECT Id From UserRole Where Name = :GlobalUtilities.ROLE_SALES_REP].Id);
        } else {
            factory.setFieldValue(User.UserRoleId, [SELECT Id From UserRole Where Name = :GlobalUtilities.ROLE_SYSTEM_ADMINISTRATOR].Id);
        }

        if (profile != '') {
            List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profile];
            if (profiles.size() != 1)
                throw new MyException ('TestObjectUtilities.generateUsers: ' + profile + ' either does not exist or has multiple matches on its name.');
            factory.setFieldValue(User.ProfileId, profiles[0].Id);
        }

        List<User> toReturn = new List<User>();
        for (Integer x = 0; x < quantity; x++) {
            Integer root = (((userCount * 1000) + x)+usernameOffset);
            factory.setFieldValue(User.CommunityNickname, 'testusernickname' + root);
            factory.setFieldValue(User.email, 'Test' + root + '@' + GlobalUtilities.MASTER_DOMAIN);
            factory.setFieldValue(User.Username, 'Test' + root + '@' + GlobalUtilities.MASTER_DOMAIN);
            factory.setFieldValue(User.LastName, 'Test' + root);
            User u = factory.createRecord(false);
            toReturn.add(u);
        }
        userCount++;
        insert toReturn;
        return toReturn;
    }

    public static List<User> generateUsers(Integer quantity) {
        return generateUsers(quantity, '');
    }
}