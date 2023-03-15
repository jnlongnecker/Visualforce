public class DoubleStackController {
	
    private String name;
    private Opportunity opp;
    private Account acc;
    
    public List<Wrapper> myValues {get; set;}
    
    public List<Opportunity> someOpps {get; set;}
    
    public DoubleStackController() {
        myValues = new List<Wrapper>();
        PageReference currPage = ApexPages.currentPage();
        
        Map<String, String> urlParams = currPage.getParameters();
        
        Id oppId = urlParams.get('oppId');
        Id accId = urlParams.get('accId');
        name = urlParams.get('name');
        
        if (name == null) {
            name = UserInfo.getName();
        }
        
        someOpps = [SELECT Name, Amount, StageName FROM Opportunity WHERE AccountId = :accId];
        opp = [SELECT Name, Amount, StageName FROM Opportunity WHERE Id = :oppId];
        acc = [SELECT Name, AnnualRevenue, Rating FROM Account WHERE Id = :accId];
        
        // Add values to the wrapper list following the format of the constructor
        myValues.add(new Wrapper('Name', 'Name', 'Name', opp, acc));
        myValues.add(new Wrapper('Money', 'Amount', 'AnnualRevenue', opp, acc));
        myValues.add(new Wrapper('Placement', 'StageName', 'Rating', opp, acc));
    }
    
    public String getGreeting() {
        return 'Hello ' + name + ', here is your info!';
    }
    
    public void Save() {
        update someOpps;
    }
    
    
    private class Wrapper {
        
        // Used to hold the general name for the info column
        String fieldName;
        
        // Used to hold the names of the fields we want on their respective sObjects
        String oppFieldName;
        String accFieldName;
        
        Account acc;
        Opportunity opp;
        
        public Wrapper(String fieldName, String oppFieldName, String accFieldName, Opportunity opp, Account acc) {
            this.fieldName = fieldName;
            this.oppFieldName = oppFieldName;
            this.accFieldName = accFieldName;
            this.acc = acc;
            this.opp = opp;
        }
        
        public String getField() {
            return fieldName;
        }
        
        /*
         * 	The get() method takes in a string as a field name and returns the value of the field
         */
        public Object getOppValue() {
            return opp.get(oppFieldName);
        }
        
        public Object getAccValue() {
            return acc.get(accFieldName);
        }
    }
}