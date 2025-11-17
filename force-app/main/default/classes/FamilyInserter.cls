public inherited sharing class FamilyInserter {

    /**
     * @description
     * @param parent
     * @param childReferencingParentsUsingExternalId
     * @example
     * String parent_IdLookup_Value = 'test2123@gmail.com';
     * Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
     * Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));
     * FamilyInserter.insertFamily(parent, child);
     **/
    public static List<Database.SaveResult> insertFamily(final SObject parent, final SObject childReferencingParentsUsingExternalId) {
        return insertFamily(new List<SObject>{parent}, new List<SObject>{childReferencingParentsUsingExternalId}, false, AccessLevel.SYSTEM_MODE);
    }

    /**
     * @description Each collection must contain the same SObject type within them,
     * but SObject type may be different between collections.
     * If multiple SObjects are required, please  use insertFamily(List<List<SObject>>>) method, passing each
     * SObject type in separate list.
     * Example: Parents list contain only Account records, and Children list contain only Contact records.
     * Parents list cannot contain both Account and Contact records.
     *
     * @param parents
     * @param childrenReferencingParentsUsingExternalId
     *
     * @return
     *
     * @example
     * String parent_IdLookup_Value = 'test2123@gmail.com';
     * String parentTwo_IdLookup_Value = 'test9977@gmail.com';
     * Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
     * Contact parentTwo = new Contact(LastName = 'parentTwo', Email = parentTwo_IdLookup_Value);
     * Contact childOne = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));
     * Contact childTwo = new Contact(LastName = 'childTwo', ReportsTo = new Contact(Email = parentTwo_IdLookup_Value));
     * Contact childThree = new Contact(LastName = 'childThree', ReportsTo = new Contact(Email = parentTwo_IdLookup_Value));
     * FamilyInserter.insertFamily(
     *     new List<SObject>{ parentOne, parentTwo },
     *     new List<SObject>{ childOne, childTwo, childThree }
     * );
     **/
    public static List<Database.SaveResult> insertFamily(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId) {
        return insertFamily(parents, childrenReferencingParentsUsingExternalId, true, AccessLevel.SYSTEM_MODE);
    }

    public static List<Database.SaveResult> insertFamily(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = separateParentAndChildWithDividingRecord(parents, childrenReferencingParentsUsingExternalId);

        return Database.insert(recordsToDml, allOrNothing, accessLevel);
    }



    public static List<Database.UpsertResult> upsertFamily(final SObject parent, final SObject childReferencingParentsUsingExternalId) {
        return upsertFamily(new List<SObject>{parent}, new List<SObject>{childReferencingParentsUsingExternalId}, true, AccessLevel.SYSTEM_MODE);
    }

    public static List<Database.UpsertResult> upsertFamily(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = separateParentAndChildWithDividingRecord(parents, childrenReferencingParentsUsingExternalId);

        return Database.upsert(recordsToDml, allOrNothing, accessLevel);
    }


    public static List<Database.UpsertResult> upsertFamilyOnField(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final SObjectField fieldOnUpsert) {
        return upsertFamilyOnField(parents, childrenReferencingParentsUsingExternalId, fieldOnUpsert, true, AccessLevel.SYSTEM_MODE);
    }


    public static List<Database.UpsertResult> upsertFamilyOnField(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final SObjectField fieldOnUpsert, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = separateParentAndChildWithDividingRecord(parents, childrenReferencingParentsUsingExternalId);

        return Database.upsert(recordsToDml, fieldOnUpsert, allOrNothing, accessLevel);
    }




    private static List<SObject> separateParentAndChildWithDividingRecord(final List<SObject> parents, final List<SObject> children) {
        final List<SObject> recordsToDml = new List<SObject>();

        recordsToDml.addAll(parents);
        recordsToDml.add(dummyRecordToSeparateChunks);
        recordsToDml.addAll(children);

        isCollectionSizeBelowThreshold(parents, children);
        return recordsToDml;
    }


    /**
     * @description
     * @param family
     * @example
     * String parentExtId = 'parent@example.com';
     * String childExtId = 'child@example.com';
     *
     * Contact parent = new Contact(LastName = 'Parent', Email = parentExtId);
     * Contact child = new Contact(LastName = 'Child', Email = childExtId,ReportsTo = new Contact(Email = parentExtId));
     * Contact grandchild = new Contact(LastName = 'Grandchild', ReportsTo = new Contact(Email = childExtId));
     *
     * List<List<SObject>> family = new List<List<SObject>>{
     *      new List<SObject>{ parent },
     *      new List<SObject>{ child },
     *      new List<SObject>{ grandchild }
     * };
     * FamilyInserter.insertFamily(family);
     **/
    public static List<Database.SaveResult> insertFamily(final List<List<SObject>> family) {
        return insertFamily(family, true, AccessLevel.SYSTEM_MODE);
    }

    public static List<Database.SaveResult> insertFamily(final List<List<SObject>> family, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = arrangeCollectionIntoChunksWithDividingRecord(family);

        return Database.insert(recordsToDml, allOrNothing, accessLevel);
    }

    public static List<Database.UpsertResult> upsertFamily(final List<List<SObject>> family) {
        return upsertFamily(family, true, AccessLevel.SYSTEM_MODE);
    }

    public static List<Database.UpsertResult> upsertFamily(final List<List<SObject>> family, final SObjectField fieldOnUpsert) {
        return upsertFamily(family, fieldOnUpsert, true, AccessLevel.SYSTEM_MODE);
    }

    public static List<Database.UpsertResult> upsertFamily(final List<List<SObject>> family, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = arrangeCollectionIntoChunksWithDividingRecord(family);

        return Database.upsert(recordsToDml, allOrNothing, accessLevel);
    }

    public static List<Database.UpsertResult> upsertFamily(final List<List<SObject>> family, final SObjectField fieldOnUpsert, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = arrangeCollectionIntoChunksWithDividingRecord(family);

        return Database.upsert(recordsToDml, fieldOnUpsert, allOrNothing, accessLevel);
    }

    private static List<SObject> arrangeCollectionIntoChunksWithDividingRecord(final List<List<SObject>> family) {
        final List<SObject> recordsToDml = new List<SObject>();

        Integer nonEmptyGroups = 0;
        Integer recordCountInChunks = 0;
        Boolean previousGroupNotEmpty = false;
        for (List<SObject> familyGroup : family) {
            if (previousGroupNotEmpty) {
                recordsToDml.add(dummyRecordToSeparateChunks);
            }
            if (familyGroup?.isEmpty() == true) {
                previousGroupNotEmpty = false;
                continue;
            }
            recordsToDml.addAll(familyGroup);
            nonEmptyGroups++;
            previousGroupNotEmpty = true;
            recordCountInChunks += Math.max(DML_CHUNK_SIZE, familyGroup.size());

            if (recordCountInChunks >= DML_MAXIMUM_RECORD_COUNT_IN_OPERATION) {
                throw new FamilyInserterRecordCountExceededException('Chunked record count exceed limit of ' + DML_MAXIMUM_RECORD_COUNT_IN_OPERATION + '. Please pass fewer records or fewer collections.');
            }

            if (nonEmptyGroups >= MAXIMUM_CHUNKS) {
                throw new FamilyInserterChunkCountExceededException('Maximum chunk count is ' + MAXIMUM_CHUNKS + '. Please pass fewer collections or fewer records.');
            }
        }

        return recordsToDml;
    }

    private static Boolean isCollectionSizeBelowThreshold(final List<SObject> parents, final List<SObject> children) {
        final Integer salesforceLimitWithoutOneChunk = DML_MAXIMUM_RECORD_COUNT_IN_OPERATION - DML_CHUNK_SIZE;   // As we do DML on different SObject types, we are limited to 9 chunks of 200 records. That one chunk is for the Dummy record separator.
        if (parents.size() + children.size() > salesforceLimitWithoutOneChunk) {
            throw new FamilyInserterRecordCountExceededException('Size sum of Parents and Children cannot exceed ' + salesforceLimitWithoutOneChunk);
        }

        return true;
    }

    private final static SObject dummyRecordToSeparateChunks {private get {return new Dummy_Object__c();}}
    private final static Integer DML_CHUNK_SIZE {private get {return 200;}}
    private final static Integer DML_MAXIMUM_RECORD_COUNT_IN_OPERATION {private get {return 2000;}}
    private final static Integer MAXIMUM_CHUNKS {private get {return 5;}} // Five, because each DummyRecord as separator counts as additional chunk

    @TestVisible private virtual class FamilyInserterException extends Exception {}
    private class FamilyInserterChunkCountExceededException extends FamilyInserterException {}
    private class FamilyInserterRecordCountExceededException extends FamilyInserterException {}

}