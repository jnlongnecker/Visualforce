public class EditTopAccountController {

    public Account acc {get; set;}
    
    /*
     * 	Transient and View State:
     * 		- The view state is the collection of component on your VF page and data in your controller
     * 		- Every time the page goes to the server, the view state is sent
     * 		- Reducing this means our pages run faster!
     * 		- Ways to reduce view state size (best practices):
     * 			- Limit <apex:form> and <apex:inputField> components (they are expensive!)
     * 			- Use <apex:outputLink> instead of <apex:commandLink> where possible (outputLink is more lightweight)
     * 			- Lazy load values so they don't get sent as part of view state while still unloaded
     * 			- Wrap <apex:actionSupport> components with <apex:actionRegion> so we only send back the minimum for the VF end
     * 			- Make sure you only query for what you need and only keep what you need
     * 			- Make sure you only use components that are necessary
     * 			- Mark properties that are not vital to the state of the page as transient
     * 		- Max size of the view state: 170KB
     */
    transient DateTime lastChange;
    
    public List<DateTime> allChanges {get; set;}
    
    public EditTopAccountController() {
        allChanges = new List<DateTime>();
        acc = [
            SELECT Name, Rating, AnnualRevenue, NumberOfEmployees 
            FROM Account
            ORDER BY AnnualRevenue DESC NULLS LAST LIMIT 1
        ];
    }
    
    public DateTime getLastChange() {
        if (lastChange == null) {
            lastChange = System.now();
            allChanges.add(System.now());
        }
        return lastChange;
    }
    
    public String getAccountLink() {
        return '/lightning/r/Account/' + acc.Id + '/view';
    }
    
    public Boolean getCanUpdate() {
        return Schema.sObjectType.Account.isUpdateable();
    }
    
    public void save() {
        if (isValid()) {
        	update acc;
        }
    }
    
    public PageReference google() {
        PageReference google = new PageReference('https://www.google.com/search');
        google.getParameters().put('q', acc.Name);
        google.setRedirect(true);
        return google;
    }
    
    /*
     * 	Runs the validation method, but discards the result because action bound methods need to return void or a PageReference
     */
    public void runValidation() {
        isValid();
    }
    
    public Boolean isValid() {
        if(!(acc.Rating == 'Hot' || acc.Rating == 'Warm')) {
            // Values for the severity enum: CONFIRM, ERROR, FATAL, INFO, WARNING
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Rating cannot be less than warm!'));
            return false;
        }
        return true;
    }
    
    public String getIFrameLink() {
        String encodedName = EncodingUtil.urlEncode(acc.Name, 'UTF-8');
        return 'https://www.google.com/search?igu=1&q=' + encodedName;
    }
    
    public Component.Apex.OutputPanel getChangeList() {
        Component.Apex.OutputPanel panel = new Component.Apex.OutputPanel();
        for (Integer i = 0; i < allChanges.size(); i++) {
            // Adds a line break before our next item in the list
            panel.childComponents.add(new Component.Apex.OutputText(escape = false, value = '<br/>'));
            Component.Apex.OutputText timestamp = new Component.Apex.OutputText();
            timestamp.expressions.value = '{!allChanges[' + i + ']}';
            panel.childComponents.add(timestamp);
        }
        
        return panel;
    }
}