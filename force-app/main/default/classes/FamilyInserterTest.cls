/**
 * Created by zanst on 27.10.2025.
 */

@IsTest
private without sharing class FamilyInserterTest {




    @IsTest
    static void testParentAndChild() {
        String parent_IdLookup_Value = 'parent';
        Dummy_Test_Object__c parent = new Dummy_Test_Object__c(Name = 'parent');
        Dummy_Test_Object__c child = new Dummy_Test_Object__c(Name = 'child', Parent__r = new Dummy_Test_Object__c(Name = parent_IdLookup_Value));

        Test.startTest();
        FamilyInserter.insertFamily(parent, child); // Throws "System.DmlException: Operation failed due to fields being inaccessible on Sobject Dummy_Test_Object__c, check errors on Exception or Result!" !!!
        Test.stopTest();

        Dummy_Test_Object__c childAfterInsert = [SELECT Id, Parent__c FROM Dummy_Test_Object__c WHERE Id = :child.Id];
        Assert.areEqual(parent.Id, childAfterInsert.Parent__c, 'Child should be linked with parent.');
    }

//    @IsTest
//    static void testFamily() {
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
//        for (Integer i = 0; i < 4; i++) {
//            family.add(new List<Dummy_Test_Object__c>{new Dummy_Test_Object__c(LastName = 'child', ReportsTo = new Dummy_Test_Object__c(Email = emailsForExternalIds[0]))});
//        }
//
//        FamilyInserter.insertFamily(family);
//    }
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

}