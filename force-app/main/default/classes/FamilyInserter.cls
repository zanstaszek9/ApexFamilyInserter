public inherited sharing class FamilyInserter {

    /**
     * @description
     * Inserts a single parent record and a single child record that references the parent
     * using an External Id field on a lookup relationship.
     *
     * @param parent The parent SObject record to insert.
     * @param childReferencingParentsUsingExternalId The child SObject that references the parent
     *                                               using a lookup based on an External Id.
     *
     * @return List<Database.SaveResult> Results of the insert operation.
     *
     * @example
     * String parent_IdLookup_Value = 'test2123@gmail.com';
     * Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
     * Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));
     * FamilyInserter.insertFamily(parent, child);
     **/
    public List<Database.SaveResult> insertFamily(final SObject parent, final SObject childReferencingParentsUsingExternalId) {
        return insertFamily(new List<SObject>{parent}, new List<SObject>{childReferencingParentsUsingExternalId}, false, AccessLevel.SYSTEM_MODE);
    }

    /**
     * @description
     * Inserts two collections of SObjects: parent records and child records.
     * Children must reference parents using lookup fields populated with External Id values.
     * Each list must contain only one SObject type (but the types may differ between lists).
     *
     * @param parents List of parent SObjects.
     * @param childrenReferencingParentsUsingExternalId List of child SObjects referencing parents using External Id.
     *
     * @return List<Database.SaveResult> Results of the insert operation.
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
    public List<Database.SaveResult> insertFamily(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId) {
        return insertFamily(parents, childrenReferencingParentsUsingExternalId, true, AccessLevel.SYSTEM_MODE);
    }

    /**
     * @description
     * Inserts parent and child records with control over allOrNothing and access level.
     * Children must reference parents via lookup using External Id.
     *
     * @param parents List of parent SObjects.
     * @param childrenReferencingParentsUsingExternalId List of child SObjects.
     * @param allOrNothing Whether the DML is atomic.
     * @param accessLevel The DML access mode.
     *
     * @return List<Database.SaveResult> Results of insertion.
     **/
    public List<Database.SaveResult> insertFamily(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = separateParentAndChildWithDividingRecord(parents, childrenReferencingParentsUsingExternalId);
        return Database.insert(recordsToDml, allOrNothing, accessLevel);
    }


    /**
     * @description
     * Performs an upsert on a parent and child SObject pair using External Id relationships.
     *
     * @param parent Parent SObject.
     * @param childReferencingParentsUsingExternalId Child referencing parent using External Id.
     *
     * @return List<Database.UpsertResult> Results of upsert.
     **/
    public List<Database.UpsertResult> upsertFamily(final SObject parent, final SObject childReferencingParentsUsingExternalId) {
        return upsertFamily(new List<SObject>{parent}, new List<SObject>{childReferencingParentsUsingExternalId}, true, AccessLevel.SYSTEM_MODE);
    }

    /**
     * @description
     * Performs an upsert operation on collections of parent and child objects.
     *
     * @param parents List of parent SObjects.
     * @param childrenReferencingParentsUsingExternalId List of child SObjects referencing parents.
     * @param allOrNothing Whether to roll back all changes if any fail.
     * @param accessLevel DML access level.
     *
     * @return List<Database.UpsertResult> Upsert results.
     **/
    public List<Database.UpsertResult> upsertFamily(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = separateParentAndChildWithDividingRecord(parents, childrenReferencingParentsUsingExternalId);
        return Database.upsert(recordsToDml, allOrNothing, accessLevel);
    }


    /**
     * @description
     * Performs an upsert operation on parents and children on a specific field.
     *
     * @param parents Parent SObjects.
     * @param childrenReferencingParentsUsingExternalId Child SObjects referencing parents.
     * @param fieldOnUpsert Field used for upsert matching.
     *
     * @return List<Database.UpsertResult> Upsert results.
     **/
    public List<Database.UpsertResult> upsertFamilyOnField(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final SObjectField fieldOnUpsert) {
        return upsertFamilyOnField(parents, childrenReferencingParentsUsingExternalId, fieldOnUpsert, true, AccessLevel.SYSTEM_MODE);
    }

    /**
     * @description
     * Upsert records using specified external Id field, with control over DML mode.
     *
     * @param parents List of parents.
     * @param childrenReferencingParentsUsingExternalId List of children.
     * @param fieldOnUpsert Field used as External Id during upsert.
     * @param allOrNothing Whether to perform atomic DML.
     * @param accessLevel Access mode for DML.
     *
     * @return List<Database.UpsertResult> Upsert results.
     **/
    public List<Database.UpsertResult> upsertFamilyOnField(final List<SObject> parents, final List<SObject> childrenReferencingParentsUsingExternalId, final SObjectField fieldOnUpsert, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = separateParentAndChildWithDividingRecord(parents, childrenReferencingParentsUsingExternalId);
        return Database.upsert(recordsToDml, fieldOnUpsert, allOrNothing, accessLevel);
    }


    /**
     * @description
     * Combines parent and child lists separated by a dummy record to enforce correct DML chunking.
     *
     * @param parents List of parent records.
     * @param children List of child records.
     *
     * @return List<SObject> Flattened structure ready for DML.
     **/
    private List<SObject> separateParentAndChildWithDividingRecord(final List<SObject> parents, final List<SObject> children) {
        final List<SObject> recordsToDml = new List<SObject>();

        recordsToDml.addAll(parents);
        recordsToDml.add(dummyRecordToSeparateChunks);
        recordsToDml.addAll(children);

        isCollectionSizeBelowThreshold(parents, children);
        return recordsToDml;
    }


    /**
     * @description
     * Inserts multiple hierarchical collections (e.g., Parent → Child → Grandchild).
     * Each inner list represents a generation or logical level.
     *
     * @param family Nested list of SObject groups, each representing one family level.
     *
     * @return List<Database.SaveResult> Results of insert operations.
     *
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
    public List<Database.SaveResult> insertFamily(final List<List<SObject>> family) {
        return insertFamily(family, true, AccessLevel.SYSTEM_MODE);
    }

    /**
     * @description
     * Inserts multiple SObject groups with control over allOrNothing and access level.
     *
     * @param family Nested list of family groups.
     * @param allOrNothing Whether DML is atomic.
     * @param accessLevel Access mode.
     *
     * @return List<Database.SaveResult> Insert results.
     **/
    public List<Database.SaveResult> insertFamily(final List<List<SObject>> family, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = arrangeCollectionIntoChunksWithDividingRecord(family);
        return Database.insert(recordsToDml, allOrNothing, accessLevel);
    }

    /**
     * @description
     * Upserts nested SObject collections (multi-level family structure).
     *
     * @param family Nested lists of SObjects.
     *
     * @return List<Database.UpsertResult> Upsert results.
     **/
    public List<Database.UpsertResult> upsertFamily(final List<List<SObject>> family) {
        return upsertFamily(family, true, AccessLevel.SYSTEM_MODE);
    }

    /**
     * @description
     * Upserts nested SObject groups using a specified External Id field.
     *
     * @param family Nested SObject collections.
     * @param fieldOnUpsert Field to match during upsert.
     *
     * @return List<Database.UpsertResult> Upsert results.
     **/
    public List<Database.UpsertResult> upsertFamily(final List<List<SObject>> family, final SObjectField fieldOnUpsert) {
        return upsertFamily(family, fieldOnUpsert, true, AccessLevel.SYSTEM_MODE);
    }

    /**
     * @description
     * Upserts nested collections with control over allOrNothing and access mode.
     *
     * @param family Nested SObject lists.
     * @param allOrNothing Whether DML is atomic.
     * @param accessLevel Access level.
     *
     * @return List<Database.UpsertResult> Upsert results.
     **/
    public List<Database.UpsertResult> upsertFamily(final List<List<SObject>> family, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = arrangeCollectionIntoChunksWithDividingRecord(family);
        return Database.upsert(recordsToDml, allOrNothing, accessLevel);
    }

    /**
     * @description
     * Upserts nested SObject groups using a custom External Id field with full DML control.
     *
     * @param family Nested lists of SObjects.
     * @param fieldOnUpsert External Id field to match on.
     * @param allOrNothing true to roll back entire operation if any record fails.
     * @param accessLevel DML access mode.
     *
     * @return List<Database.UpsertResult> Upsert results.
     **/
    public List<Database.UpsertResult> upsertFamily(final List<List<SObject>> family, final SObjectField fieldOnUpsert, final Boolean allOrNothing, final AccessLevel accessLevel) {
        final List<SObject> recordsToDml = arrangeCollectionIntoChunksWithDividingRecord(family);
        return Database.upsert(recordsToDml, fieldOnUpsert, allOrNothing, accessLevel);
    }

    /**
     * @description
     * Flattens nested family collections into a single sequence separated by dummy records
     * to enforce correct chunking during DML.
     *
     * @param family Nested list of SObject groups.
     *
     * @return List<SObject> Prepared DML list.
     **/
    private List<SObject> arrangeCollectionIntoChunksWithDividingRecord(final List<List<SObject>> family) {
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

    /**
     * @description
     * Ensures that the combined parent + child list size does not exceed Salesforce DML chunk thresholds.
     *
     * @param parents Parent SObjects.
     * @param children Child SObjects.
     *
     * @return Boolean true if within limits.
     **/
    private Boolean isCollectionSizeBelowThreshold(final List<SObject> parents, final List<SObject> children) {
        final Integer salesforceLimitWithoutOneChunk = DML_MAXIMUM_RECORD_COUNT_IN_OPERATION - DML_CHUNK_SIZE;
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
