public inherited sharing class FamilyInserter {

    /**
     * @description
     * @param parent
     * @param childReferencingParentsUsingExternalId
     * @example
     * String parent_IdLookup_Value = 'test2123@gmai.com';
     * Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
     * Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));
     * FamilyInserter.insertFamily(parent, child);
     **/
    public static void insertFamily(final SObject parent, final SObject childReferencingParentsUsingExternalId) {
        insertFamily(new List<SObject>{parent}, new List<SObject>{childReferencingParentsUsingExternalId});
    }

    /**
     * @description Each collection must contain the same SObject type within them,
     * but SObject type may be different between collections.
     * If multiple SObjects are required, please  use insertFamily(List<List<SObject>>>) method, passing each
     * SObject type in separate list.
     * Example: Parents list contain only Account records, and Children list contain only Contact records.
     * Parents list cannot contain both Account and Contact records.
     * @param parents
     * @param childrenReferencingParentsUsingExternalId
     * @example
     * String parent_IdLookup_Value = 'test2123@gmai.com';
     * Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);    //TODO
     * Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));
     * FamilyInserter.insertFamily(parent, child);
     **/
    public static void insertFamily(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId) {
        final List<SObject> recordsToDml = prepareRecords(parents, childrenReferencingParentsUsingExternalId);

        insert as user recordsToDml;
    }

    public static void upsertFamily(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId) {
        final List<SObject> recordsToDml = prepareRecords(parents, childrenReferencingParentsUsingExternalId);

        upsert as user recordsToDml;
    }


    public static List<Database.UpsertResult> upsertFamilyOnField(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final SObjectField fieldOnUpsert) {
        final List<SObject> recordsToDml = prepareRecords(parents, childrenReferencingParentsUsingExternalId);

        return Database.upsert(recordsToDml, fieldOnUpsert, AccessLevel.USER_MODE);
    }




    private static List<SObject> prepareRecords(final List<SObject> parents, final List<SObject> children) {
        final List<SObject> recordsToDml = new List<SObject>();

        recordsToDml.addAll(parents);
        recordsToDml.add(dummyRecordToSeparateChunks);
        recordsToDml.addAll(children);

        isCollectionSizeBelowThreshold(parents, children);
        return recordsToDml;
    }


    public static void insertFamily(final List<List<SObject>> family) {
        final List<SObject> recordsToDml = arrangeCollectionIntoChunksWithDividingRecord(family);

        insert as user recordsToDml;
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