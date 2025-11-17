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
 String parent_IdLookup_Value = 'test2123@gmail.com';
 Contact parent = new Contact(LastName = 'parent', Email = parent_IdLookup_Value);
 Contact child = new Contact(LastName = 'child', ReportsTo = new Contact(Email = parent_IdLookup_Value));

 new FamilyInserter().insertFamily(parent, child);
```

## Limitations
- Cannot run UPSERTs referencing specific fields, like `upsert contactRecord Email;`, due to potential name collisions 
- Maximum 5 levels of hierarchy
- All limitation declared in following docs:
  - [Creating Parent and Child Records in a Single Statement Using Foreign Keys](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_dml_foreign_keys.htm)
  - [Creating Records for Different Object Types
     ](https://developer.salesforce.com/docs/atlas.en-us.258.0.api.meta/api/sforce_api_calls_create.htm#MixedSaveSection)
