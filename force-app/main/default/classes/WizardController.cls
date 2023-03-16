public with sharing class WizardController {

    Map<String, Account> nameToAccount;
    Map<String, Opportunity> nameToOpportunity;
    
    // Used to hold the user's preferred name
    public String desiredName {get; set;}
    // Used to hold the result from the first selectList for Accounts
    public String chosenAcc {get; set;}
    // Used to hold the result from the second selectList for Opportunities
    public String chosenOpp {get; set;}
    
    public WizardController() {
        nameToAccount = new Map<String, Account>();
        nameToOpportunity = new Map<String, Opportunity>();
        
        // Retrieves a list of account with opportunities, but only ones that have related opportunities
        List<Account> choices = [SELECT Name, (SELECT Name FROM Opportunities) FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity)];
        
        // Constructing our maps
        for (Account acc : choices) {
            nameToAccount.put(acc.Name, acc);
            for (Opportunity opp : acc.Opportunities) {
                nameToOpportunity.put(opp.Name, opp);
            }
        }
        
        // Allows you to get the name of the user without asking
        // UserInfo.getName()
    }
    
    /*
     * 	Retrieves a list of options for the apex:selectOptions component (for accounts)
     */
    public List<SelectOption> getAccountChoices() {
        // SelectOption represents a single choice
        List<SelectOption> choices = new List<SelectOption>();
        
        for (String accName : nameToAccount.keySet()) {
            // First Value: Display value, Second Value: Value that gets saved
            choices.add(new SelectOption(accName, accName));
        }
        
        return choices;
    }
    
    /*
     * 	Retrieves a list of options for the apex:selectOptions component (for opportunities)
     */
    public List<SelectOption> getOpportunityChoices() {
        List<SelectOption> choices = new List<SelectOption>();
        List<Opportunity> oppChoices = nameToAccount.get(chosenAcc).Opportunities;
        
        for (Opportunity opp : oppChoices) {
            choices.add(new SelectOption(opp.Name, opp.Name));
        }
        
        return choices;
    }
    
    
    /*
     * 	Returns the WizardOpp visualforce page to change pages to that one
     */
    public PageReference oppSelectPage() {
        // Page class contains all references to visualforce pages
        PageReference nextPage = Page.WizardOpp;
        return nextPage;
    }
    
    /*
     * 	Returns the WizardAcc page to change pages
     */
    public PageReference accSelectPage() {
        PageReference previousPage = Page.WizardAcc;
        return previousPage;
    }
    
    private Id getChosenOppId() {
        Opportunity chosen = nameToOpportunity.get(chosenOpp);
        return chosen.Id;
    }
    
    private Id getChosenAccId() {
		Account chosen = nameToAccount.get(chosenAcc);
		return chosen.Id;        
    }
    
    /*
     * 	Populates url parameters and changes to the final page
     */
    public PageReference finish() {
        PageReference finalPage = Page.DoubleStack;
        
        // Used to place parameters in the URL
        finalPage.getParameters().put('accId', getChosenAccId());
        finalPage.getParameters().put('oppId', getChosenOppId());
        finalPage.getParameters().put('name', desiredName);
        return finalPage;
    }
}