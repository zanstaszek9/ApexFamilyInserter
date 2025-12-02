@IsTest
private class EmptyRecycleBinTest {
    @IsTest
    static void emptyRecycleBinFromSingleRecord() {
        Dummy_Test_Object__c recordToDelete = new Dummy_Test_Object__c(Name = 'anyName');
        insert recordToDelete;
        delete recordToDelete;

        Assert.areEqual(1, [SELECT COUNT() FROM Dummy_Test_Object__c WHERE IsDeleted = TRUE AND Id = :recordToDelete.Id ALL ROWS], 'Record should not be hard deleted yet.');

        Test.startTest();
        EmptyRecycleBin.Requests deleteRequests = new EmptyRecycleBin.Requests();
        deleteRequests.sobj = recordToDelete;
        EmptyRecycleBin.execute(new List<EmptyRecycleBin.Requests>{deleteRequests});
        Integer dmlsAfterEmptyingRecycleBin = Limits.getDmlStatements();
        Test.stopTest();

//        Assert.areEqual(0, [SELECT COUNT() FROM Dummy_Test_Object__c WHERE IsDeleted = TRUE AND Id = :recordToDelete.Id ALL ROWS], 'Record should be hard deleted.'); // "Database.emptyRecycleBin()" does not work in Unit tests, so that check would fail. https://salesforce.stackexchange.com/questions/27180/database-emptyrecyclebin-exhibits-unexpected-behaviour
        Assert.areEqual(1, dmlsAfterEmptyingRecycleBin, 'Emptying recycle bin had run.');
    }

    @IsTest
    static void emptyRecycleBinFromManyRecords() {
        List<Dummy_Test_Object__c> recordListToDelete = new List<Dummy_Test_Object__c>{
                new Dummy_Test_Object__c(Name = 'anyName1'),
                new Dummy_Test_Object__c(Name = 'anyName2')
        };
        insert recordListToDelete;
        delete recordListToDelete;

        Assert.areEqual(2, [SELECT COUNT() FROM Dummy_Test_Object__c WHERE IsDeleted = TRUE AND Id IN :recordListToDelete ALL ROWS], 'Records should not be hard deleted yet.');

        Test.startTest();
        EmptyRecycleBin.Requests deleteRequests = new EmptyRecycleBin.Requests();
        deleteRequests.listOfSObjects = recordListToDelete;
        EmptyRecycleBin.execute(new List<EmptyRecycleBin.Requests>{deleteRequests});
        Integer dmlsAfterEmptyingRecycleBin = Limits.getDmlStatements();
        Test.stopTest();

//        Assert.areEqual(0, [SELECT COUNT() FROM Dummy_Test_Object__c WHERE IsDeleted = TRUE AND Id = :recordListToDelete ALL ROWS], 'Records should be hard deleted.'); // "Database.emptyRecycleBin()" does not work in Unit tests, so that check would fail. https://salesforce.stackexchange.com/questions/27180/database-emptyrecyclebin-exhibits-unexpected-behaviour
        Assert.areEqual(1, dmlsAfterEmptyingRecycleBin, 'Emptying recycle bin had run.');
    }
}