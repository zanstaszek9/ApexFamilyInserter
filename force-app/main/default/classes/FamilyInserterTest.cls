@IsTest
private class FamilyInserterTest {

    @TestSetup
    static void setup() {
        createUserWithRequiredPermissionSet();
    }


    @IsTest
    static void testParentAndChild() {
        String parent_IdLookup_Value = 'parent';
        Dummy_Test_Object__c parent = new Dummy_Test_Object__c(Name = parent_IdLookup_Value);
        Dummy_Test_Object__c child = new Dummy_Test_Object__c(Name = 'child', Parent__r = new Dummy_Test_Object__c(Name = parent_IdLookup_Value));

        Test.startTest();
        System.runAs(getUserWithPermissions()) {
            FamilyInserter.insertFamily(parent, child);
        }
        Test.stopTest();

        Dummy_Test_Object__c childAfterInsert = [SELECT Id, Parent__c FROM Dummy_Test_Object__c WHERE Id = :child.Id];
        Assert.areEqual(parent.Id, childAfterInsert.Parent__c, 'Child should be linked with parent.');
    }

    @IsTest
    static void testParentAndChildAndGrandchild() {
        String parent_IdLookup_Value = 'parent';
        String child_IdLookup_Value = 'child';
        Dummy_Test_Object__c parent = new Dummy_Test_Object__c(Name = parent_IdLookup_Value);
        Dummy_Test_Object__c child = new Dummy_Test_Object__c(Name = child_IdLookup_Value, Parent__r = new Dummy_Test_Object__c(Name = parent_IdLookup_Value));
        Dummy_Test_Object__c grandchild = new Dummy_Test_Object__c(Name = 'grandchild', Parent__r = new Dummy_Test_Object__c(Name = child_IdLookup_Value));

        Test.startTest();
        System.runAs(getUserWithPermissions()) {
            List<List<SObject>> family = new List<List<SObject>>{
                    new List<Dummy_Test_Object__c>{parent},
                    new List<Dummy_Test_Object__c>{child},
                    new List<Dummy_Test_Object__c>{grandchild}
            };
            FamilyInserter.insertFamily(family);
        }
        Test.stopTest();

        Dummy_Test_Object__c grandchildAfterInsert = [SELECT Id, Parent__c, Parent__r.Parent__c FROM Dummy_Test_Object__c WHERE Id = :grandchild.Id];
        Assert.areEqual(child.Id, grandchildAfterInsert.Parent__c, 'Grandchild should be linked with middle parent.');
        Assert.areEqual(parent.Id, grandchildAfterInsert.Parent__r.Parent__c, 'Child should be linked with top parent.');
    }
//
//
//
//
//    @IsTest
//    static void testFamilyTooManyMembers() {
//        List<Dummy_Test_Object__c> parents = new List<Dummy_Test_Object__c>();
//        List<String> emailsForExternalIds = new List<String>();
//
//        for (Integer i = 0; i < 200; i++) {
//            String emailExtId = 'testvv'+i+'@gmai.com';
//            parents.add(new Dummy_Test_Object__c(LastName = 'parent', Email = emailExtId));
//            emailsForExternalIds.add(emailExtId);
//        }
//
//        List<List<SObject>> family = new List<List<SObject>>();
//        family.add(parents);
//
//        for (Integer i = 0; i < 5; i++) {
//            family.add(new List<Dummy_Test_Object__c>{new Dummy_Test_Object__c(LastName = 'child', ReportsTo = new Dummy_Test_Object__c(Email = emailsForExternalIds[0]))});
//        }
//
//        try {
//            FamilyInserter.insertFamily(family);
//            Assert.fail('Should throw exception!');
//        }
//        catch (Exception e) {
//            // TODO Catch certain exception
//        }
//        Assert.isTrue(true, 'Exception thrown');
//    }



    private static final String USER_EMAIL_FOR_TEST_USER = 'familiInserterUserTest@testorg.com';

    private static void createUserWithRequiredPermissionSet() {
        try {
            final String permissionSetName = 'FamilyInserter_AdminUser';
            final User userWithPermissions = new User(Alias = 'standt', Email = USER_EMAIL_FOR_TEST_USER,
                    EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US', Profile = new Profile(Name = 'Minimum Access - Salesforce'),
                    TimeZoneSidKey = 'America/Los_Angeles', Username = USER_EMAIL_FOR_TEST_USER);

            insert new List<SObject>{
                    userWithPermissions,
                    new PermissionSetAssignment(
                            PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName].Id,
                            Assignee = new User(Email = userWithPermissions.Email)
                    )
            };
        }
        catch (Exception anyException) {
            final String message = 'Cannot create User with required permission in TestSetup. Full message: ' + anyException;
            throw new FamilyInserterTestException(message);
        }
    }

    private static User getUserWithPermissions() {
        try {
            return [SELECT Id FROM User WHERE Email = :USER_EMAIL_FOR_TEST_USER];
        }
        catch (Exception anyException) {
            final String message = 'Created User with required permission could not been retrieved. Full message: ' + anyException;
            throw new FamilyInserterTestException(message);
        }
    }


    private class FamilyInserterTestException extends Exception {}
}