public class BasicExtension {
    public Integer property {get; set;}
    private ApexPages.StandardSetController pageSetController;
    private ApexPages.StandardController pageController;

    private Account myAccount;
    
    public BasicExtension(ApexPages.StandardSetController controller) {
        pageSetController = controller;
        if (pageSetController.getRecords().size() == 0) {
            List<Account> accounts30 = [SELECT Name FROM Account LIMIT 30];
            pageSetController.setSelected(accounts30);
            myAccount = (Account)pageSetController.getRecord();
        }
        else {
            myAccount = [SELECT Name FROM Account LIMIT 1];
        }
    }
    
    public BasicExtension(ApexPages.StandardController controller) {
        pageController = controller;
        if (pageController.getRecord() != null) {
            myAccount = (Account)pageController.getRecord();
        }
        else {
            myAccount = [SELECT Name FROM Account LIMIT 1];
        }
    }
    
    public String getCustom() {
        // Do custom stuff

        return 'The current Acccount is: ' + myAccount.Name + '!';
    }
}