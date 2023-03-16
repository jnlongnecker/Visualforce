public without sharing class SecurityInApex {
	/*
	 * 	First way to enforce security takes place in the class name itself:
	 * 		- Sharing keywords
	 * 		- 3 Kinds:
	 * 			- with sharing		: Sharing settings are respected (record level access enforced)
	 * 			- without sharing	: Sharing settings are ignored (record level access not enforced)
	 * 			- inherited sharing	: Whether or not sharing is respected or ignored is determined by what calls this class
	 * 				- EX: ClassA and ClassB and ClassC
	 * 					- ClassA : with sharing
	 * 					- ClassB : inherited sharing
	 * 					- ClassC : without sharing
	 * 					- ClassA { ClassB.runMethod(); } -> this results in with sharing being enforced
	 * 					- ClassC { ClassB.runMethod(); } -> this results in without sharing being enforced
	 * 		- If no sharing keyword is specified:
	 * 			- If the class is the entry point for the transaction, it acts as without sharing
	 * 			- If the class is NOT the entry point for the transaction, it acts as inherited sharing
	 * 		- If inherited sharing starts the transaction:
	 * 			- It acts as with sharing
	 * 		- This impacts:
	 * 			- SOQL and SOSL (rows returned)
	 * 			- DML (If you don't have access to a record, you don't have access to it's id, 
	 * 					so you may fail the DML trying to relate to a record you can't access)
	 */
    
    /*
     * 	For enforcing object and field level security; we have more options
     */
    public static void securityClauses() {
        /*
         * 	Throws an exception if the user does not have read access to a field or to an object
         * 	Does NOT enforce this for polymorphic relationship fields except Owner, CreatedBy, and LastModifiedBy
         *  Only enforces data returned from SELECT and FROM
         */
        try {
            List<Account> uglySolution = [SELECT Name, Rating FROM Account WITH SECURITY_ENFORCED];
        }
        catch(System.QueryException e) {
            System.debug('You don\'t have access! Womp womp');
        }
        
        /*
         * 	WITH USER_MODE also is going to throw an exception for inaccessible fields in SOQL
         *  - However, it runs for ALL clauses
         *  - Runs for all polymorphic relationships
         *  - It will catch ALL errors instead of just the first one
         *  - If you MUST use one, use WITH USER_MODE instead
         */
        try {
            List<Account> slightlyLessUgly = [SELECT Name, Rating FROM Account WITH USER_MODE]; // Default is WITH SYSTEM_MODE
        }
        catch(System.QueryException e) {
            System.debug(e.getInaccessibleFields());
        }
    }
    
    public static void securityMethod() {
        /*
         * 	A more elegant method is using the Security.stripInaccessible() method
         * 		- Takes 3 arguments:
         * 			- Access type enum
         * 				- AccessType.READABLE
         * 				- AccessType.UPDATABLE
         * 				- AccessType.CREATEABLE
         * 				- AccessType.UPSERTABLE
         * 			- List<sObject> toFilter : This is the object list you want to filter
         * 			- Boolean checkSObj : Determines whether or not to throw an exception if the user does not have this access for the object
         * 				- Optional: Defaults to true
         */
        List<Account> unfilteredAccounts = [SELECT Name, Rating FROM Account];
        SObjectAccessDecision objDecision = Security.stripInaccessible(AccessType.READABLE, unfilteredAccounts);
        // Can also shorthand to:
        // SObjectAccessDecision objDecision = Security.stripInaccessible(AccessType.READABLE, [SELECT Name, Rating FROM Account]);
        List<Account> filteredAccounts = (List<Account>) objDecision.getRecords();
    }
    
    public static void securitySchema() {
        /*
         * 	The most precise solution uses the Schema class
         *  	- We have methods for all kinds of access
         * 			- Ex: isAccessible(), isCreateable(), isUpdateable()
         * 		- While the methods are good, they are not intuitive to access
         */
        
        /* 
         * Schema.sObjectType.Account : gives the DescribeSobjectResult for the Account object
         * This is a class that holds lots of information about the particular object
         * INCLUDING our methods we outlined above
         */
        if (Schema.sObjectType.Account.isCreateable()) {
            System.debug('The context user has Create access on Accounts!');
        }
        else {
            System.debug('The context user DOES NOT have Create access on Accounts!');
        }
        
        /*
         * 	We can do the same thing for field describes as well:
         *  Schema.sObjectType.Account.fields.rating : gives the DescribeFieldResult for the Rating field
         */
        if (Schema.sObjectType.Account.fields.rating.isAccessible()) {
            System.debug('The context user can Read the Rating field on Account!');
        }
    }
    
    public static void sharingApex() {
        /*
         * 	Apex Managed Sharing is creating new share objects to give access to users with more flexibility than sharing rules
         * 	and less work than manual sharing
         * 
         * 	- Use cases:
         * 		- Reasons for sharing are very complicated
         * 		- Must share large amount of records
         * 		- Want to give record access as part of an app
         * 		- Want to give temporary record access for an app/other reason
         */
        List<Account> allAccounts = [SELECT AnnualRevenue, NumberOfEmployees FROM Account WHERE AnnualRevenue > 0 AND NumberOfEmployees > 0];
        List<Account> accountsToShare = new List<Account>();
        
        for (Account acc : allAccounts) {
            Double revenueToEmployeeRatio = acc.AnnualRevenue / acc.NumberOfEmployees;
            if (revenueToEmployeeRatio > 50000) {
            	accountsToShare.add(acc);
            }
        }
        
        User devon = [SELECT Id FROM User WHERE Name = 'Devon Demo'];
        
        /*
         * 	Sharing in Salesforce is calculated through a special object called the Share object
         * 	- The Share object looks differently for each object
         * 		- For Standard Objects:
         * 			- ObjectNameShare
         * 			- EX: AccountShare
         * 		- For Custom Objects:
         * 			- CustomObjectName__Share
         * 			- EX: Class__Share
         * 	- The Share object has several fields to be populated:
         * 		- RecordId : Takes the record id of the record to be shared
         * 			- This is different for every Share object
         * 			- EX: AccountId for the AccountShare object
         * 		- RecordAccessLevel : Takes one of 3 values as a string: Read, Edit, or All
         * 			- This is different for every Share object
         * 			- EX: AccountAccessLevel for the AccountShare object
         * 		- UserOrGroupId : Takes the Id of a User or Public Group to share with
         * 			- This is the same for every Share object
         * 		- RowCause : The reason for the Share
         * 			- Optional, the default is RowCause.Manual
         * 			- Values can be: RowCause.Manual, RowCause.Owner, RowCause.Rule, RowCause.ImplicitChild
         * 			- You should only use RowCause.Manual
         * 			- We can create new RowCause reasons for custom objects only (and only in SF Classic)
         * 			- EX: Schema.AccountShare.RowCause.Manual for the AccountShare object
         */
        
       	List<AccountShare> newShares = new List<AccountShare>();
        
        for (Account acc : accountsToShare) {
            AccountShare newShare = new AccountShare();
            newShare.AccountAccessLevel = 'Read';
            newShare.AccountId = acc.Id;
            newShare.UserOrGroupId = devon.Id;
            newShare.OpportunityAccessLevel = 'Read';
            
            newShares.add(newShare);
        }
        
        insert newShares;
    }
    
}