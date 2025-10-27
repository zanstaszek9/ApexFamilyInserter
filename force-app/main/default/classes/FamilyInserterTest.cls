/**
 * Created by zanst on 27.10.2025.
 */

@IsTest
private class FamilyInserterTest {

    @IsTest
    static void testParentAndChild() {
        String parent_IdLookup_Value = 'test2123@gmai.com';
        Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
        Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));

        Test.startTest();
        FamilyInserter.insertFamily(parent, child);
        Test.stopTest();

        Contact childAfterInsert = [SELECT Id, ReportsToId FROM Contact WHERE Id = :child.Id];
        Assert.areEqual(parent.Id, childAfterInsert.ReportsToId, 'Child should be linked with parent.');
    }

    @IsTest
    static void testFamily() {
        List<Contact> parents = new List<Contact>();
        List<String> emailsForExternalIds = new List<String>();

        for (Integer i = 0; i < 200; i++) {
            String emailExtId = 'testvv'+i+'@gmai.com';
            parents.add(new Contact(LastName = 'parent', Email = emailExtId));
            emailsForExternalIds.add(emailExtId);
        }

        List<List<SObject>> family = new List<List<SObject>>();
        family.add(parents);

        for (Integer i = 0; i < 4; i++) {
            family.add(new List<Contact>{new Contact(LastName = 'child', ReportsTo = new Contact(Email = emailsForExternalIds[0]))});
        }

        FamilyInserter.insertFamily(family);
    }




    @IsTest
    static void testFamilyTooManyMembers() {
        List<Contact> parents = new List<Contact>();
        List<String> emailsForExternalIds = new List<String>();

        for (Integer i = 0; i < 200; i++) {
            String emailExtId = 'testvv'+i+'@gmai.com';
            parents.add(new Contact(LastName = 'parent', Email = emailExtId));
            emailsForExternalIds.add(emailExtId);
        }

        List<List<SObject>> family = new List<List<SObject>>();
        family.add(parents);

        for (Integer i = 0; i < 5; i++) {
            family.add(new List<Contact>{new Contact(LastName = 'child', ReportsTo = new Contact(Email = emailsForExternalIds[0]))});
        }

        try {
            FamilyInserter.insertFamily(family);
            Assert.fail('Should throw exception!');
        }
        catch (Exception e) {
            // TODO Catch certain exception
        }
        Assert.isTrue(true, 'Exception thrown');
    }
}