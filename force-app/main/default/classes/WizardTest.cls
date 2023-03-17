@isTest
public class WizardTest {
	
    @isTest
    public static void TP_oppSelectPage() {
        
        // Use Test.setCurrentPage() to work with pages within a test environment
        Test.setCurrentPage(Page.WizardAcc);
        WizardController wiz = new WizardController();
        
        // Set our page to the next page to ensure the oppSelectPage method gives the right page reference.
        Test.setCurrentPageReference(wiz.oppSelectPage());
        
        // Ensure the url's are equal to make sure the same page is being displayed.
        System.assertEquals(Page.WizardOpp.getUrl(), ApexPages.currentPage().getUrl());
    }
    
    @isTest
    public static void TP_ExtensionSetup() {
        
        // Create a testing account
        Account testAccount = new Account(name = 'sample account');
        insert testAccount;
        
        // Set our current page to the page related to the controller
        Test.setCurrentPage(Page.VFDemo);
        
        // Put the id of the account as a parameter to the page, since VF pages related to a record have the record id as a parameter
        ApexPages.currentPage().getParameters().put('id', testAccount.id);
        
        // Create the proper standard controller so we can call our constructor
        ApexPages.StandardController sController = new ApexPages.StandardController(testAccount);
        
        // Create our extension and make sure the account gets set correctly
        DemoExtension extension = new DemoExtension(sController);
        
        System.assertEquals(extension.myAccount.id, testAccount.id);
    }
}