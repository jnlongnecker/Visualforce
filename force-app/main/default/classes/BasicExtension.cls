public class BasicExtension {
	
    
    public List<Opportunity> opps { get; private set; }
    private ApexPages.StandardSetController pageController;
    private Id recordId;
    
    /* 
     * 	A Visualforce controller extension must have a constructor with 1 parameter:
     * 		- This parameter depends on the controller the extension is extending
     * 		- For a standard controller: ApexPages.StandardController
     * 		- For a standard set controller: ApexPages.StandardSetController
     * 		- For a custom controller: MyCustomController
     */
    public BasicExtension(ApexPages.StandardSetController controller) {
        pageController = controller;
        // We can access parameters in the URL like this:
        // Id recordId = ApexPages.currentPage().getParameters().get('id');
        PageReference currPage = ApexPages.currentPage();
        
        // URL parameters are in a key-value pair, which is the structure of a map!
        Map<String, String> parameters = currPage.getParameters();
        
        // Use the .get() method to retrieve the value for a particular parameter
        recordId = parameters.get('id');
        
        opps = [SELECT Account.Name, Amount, StageName FROM Opportunity LIMIT 20];
    }
    
    
    public void next() {
        // We can reuse functionality from the controller we're extending!
        pageController.next();
        System.debug('Advancing!');
    }
    
    public String getCustomValue() {
        
        return String.valueOf(Math.random() * 10000);
    }
    
    
}