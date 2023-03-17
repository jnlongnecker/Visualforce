public class TestController {
    public Account acc {get; set;}
    
    List<DateTime> allChanges;
    transient DateTime lastChange;
    
    public TestController() {
        allChanges = new List<DateTime>();
        acc = [SELECT Name, Rating, AnnualRevenue, NumberOfEmployees FROM Account ORDER BY AnnualRevenue DESC NULLS LAST LIMIT 1];
    }
    
    public String getAccountLink() {
        return '/lightning/r/Account/' + acc.Id + '/view';
    }
    
    public Boolean getCanUpdate() {
        return Schema.sObjectType.Account.isUpdateable();
    }
    
    public void runValidation() {
        validate();
    }
    
    public DateTime getLastChange() {
        if (lastChange == null) {
            lastChange = System.now();
            allChanges.add(System.now());
        }
        return lastChange;
    }
    
    public Component.Apex.OutputPanel getChangeList() {
        Component.Apex.OutputPanel panel = new Component.Apex.OutputPanel();
        for (DateTime dt : allChanges) {
            Component.Apex.OutputText change = new Component.Apex.OutputText();
            change.escape = false;
            change.value = '<br/>';
            change.value += dt.format();
            panel.childComponents.add(change);
        }
        return panel;
    }
    
    public Boolean validate() {
        if (acc.Rating != 'Hot') {
            // Values: CONFIRM, ERROR, FATAL, INFO, WARNING
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Must be hot!'));
            return false;
        }
        return true;
    }
    
    public void save() {
        if (!validate()) return;
        
        update acc;
    }
    
    public PageReference google() {
        PageReference google = new PageReference('https://www.google.com/search');
        google.getParameters().put('q', acc.Name);
        google.setRedirect(true);
        return google;
    }
    
    public String getIFrameLink() {
        return 'https://google.com/search?igu=1&q=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8');
    }
}