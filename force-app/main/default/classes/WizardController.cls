public class WizardController {
    public String name {get; set;}
    public Integer specialNumber {get; set;}
    public String specialText {get; set;}
    
    public WizardController() {
        name = null;
        specialNumber = null;
        specialText = null;
    }
    
    public PageReference NextPage() {
        return Page.Wizard2;
    }
    
    public PageReference PrevPage() {
        return Page.Wizard1;
    }
    
    public PageReference GoogleMethod() {
        PageReference googlePage = new PageReference('http://www.google.com/search?q=' + name);
        // We can access parameters using ApexPages.currentPage().getParameters()
        // This returns a map of keys to values
        googlePage.setRedirect(true);
        return googlePage;
    }
    
}