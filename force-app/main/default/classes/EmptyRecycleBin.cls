/**
* @description Deletes records from Recycle Bin. Taken from Automation Champion: https://automationchampion.com/2023/05/22/hard-delete-records-using-salesforce-flow-2/
* @author Rakesh Gupta. https://automationchampion.com/contact-us/, https://x.com/rakeshistom
**/

public inherited sharing class EmptyRecycleBin {

    @InvocableMethod(Label='Empty RecycleBin'
            Description='Permanently delete the records from the Recycle Bin.'
            IconName='slds:standard:record_delete'
            Category='Custom Apex Actions')
    public static void execute(final List<Requests> requestList) {

        final List<SObject> recordsToDelete = new List<SObject>();

        for (Requests req : requestList) {
            if (req.sobj != null) {
                recordsToDelete.add(req.sobj);
            }
            if (req.listOfSObjects?.isEmpty() == false) {
                recordsToDelete.addAll(req.listOfSObjects);
            }
        }

        if (recordsToDelete.size() > 0) {
            Database.emptyRecycleBin(recordsToDelete);
        }
    }

    public class Requests {

        @InvocableVariable(Description='Accept one record of an SObject type.' Required=false)
        public SObject sobj;

        @InvocableVariable(Description='Accept multiple records of an SObject type.' Required=false)
        public List<SObject> listOfSObjects;
    }
}