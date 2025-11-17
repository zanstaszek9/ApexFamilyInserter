# ApexFamilyInserter

**Apex Family Inserter** is a lightweight Apex utility that allows inserting parent and child records of the **same SObject type** in a single operation.  
It is especially useful when inserting hierarchical data models (for example: Family → Children → Grandchildren) without relying on multiple DML operations or manual ID wiring.

---

## 🚀 Features

- Insert a parent record together with its full tree of children in a single operation.
- Supports recursive, multi-level hierarchies.
- Provides test utilities and dedicated Permission Sets:
    - **FamilyInserter_AdminUser**
    - **FamilyInserter_EndUser**

---

## 📦 Example Usage

```apex
 String parent_IdLookup_Value = 'charlie@email.com';
 Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
 Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));

 new FamilyInserter().insertFamily(parent, child);
```

## Limitations
- Cannot run UPSERTs referencing specific fields, like `upsert contactRecord Email;`
- Maximum 5 levels of hierarchy
- All limitation declared in following docs:
  - [Creating Parent and Child Records in a Single Statement Using Foreign Keys](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_dml_foreign_keys.htm)
  - [Creating Records for Different Object Types
     ](https://developer.salesforce.com/docs/atlas.en-us.258.0.api.meta/api/sforce_api_calls_create.htm#MixedSaveSection)


## What does it solve?

Apex allows to create both Parent and Child record in a single DML statement **only when** Parent and Child are of **different** SObject types. 
It is done by calling DML operation on the list of SObject, and Child must reference Parent by *ExternalId* (or *IdLookUp*) field, like so:
```apex
String parent_IdLookup_Value = 'adam@email.com';
Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
Case child = new Case(Subject = 'child', Contact = new Contact(Email = parent_IdLookup_Value));
insert new List<SObject>{parent, child};

Assert.areEqual(parent.Id, [SELECT ContactId FROM Case WHERE Id = :child.Id].ContactId); // ✅ Passes 
```

However, the same SObject type cannot be used for both Parent and Child, as stated in the [documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_dml_limitations.htm#:~:text=You%20can%E2%80%99t%20add,the%20input%20array.). Doing so throws `DML Exception`:
```apex
String parent_IdLookup_Value = 'bob@email.com';
Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));

insert new List<SObject>{parent, child}; // ❌ Throws "DmlException: Insert failed. First exception on row 1; first error: INVALID_FIELD, Foreign key external ID: bob@email.com not found for field Email in entity Contact: []"
```

**Family Inserter** class allows you to insert both with single-statement, consuming only 1 resource of *DML Statements* limit:  

```apex
String parent_IdLookup_Value = 'charlie@email.com';
Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));

new FamilyInserter().insertFamily(parent, child);

Assert.areEqual(1, Limits.getDmlStatements());  // ✅ Passes 
```


## How does it work?

Salesforce splits mixed-object inserts [into chunks by SObject type and commits each chunk separately](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_dml_limitations.htm#:~:text=Records%20for%20multiple%20object%20types%20are%20broken%20into%20multiple%20chunks%20by%20Salesforce.%20A%20chunk%20is%20a%20subset%20of%20the%20input%20array%2C%20and%20each%20chunk%20contains%20records%20of%20one%20object%20type.%20Data%20is%20committed%20on%20a%20chunk%2Dby%2Dchunk%20basis.).
Different types work because the Parent chunk commits **before** the Child chunk.

To mimic this for same-type records, `FamilyInserter` inserts:
```apex
insert new List<SObject>{parent, dummyObjectSeparator, child};
````
The `Dummy Object` forces Salesforce to create separate chunks and commit Parent first. The `Dummy Object` record is being deleted and flushed on **After-Delete Flow with Async Path**, to not perform any additional DML in the same transaction. 

Chunking also occurs naturally for batches over 200 records, but `FamilyInserter` always enforces separation explicitly. Assuming Parent and Child are separated by record count looks not reliable enough for the black-box usage of `.insertFamily(parentsAndChildCollection)`.


### Other
Thanks for [Derek F](https://salesforce.stackexchange.com/users/24889/derek-f) for inspiring to dig into that and pursue semi-useless Apex knowledge.
