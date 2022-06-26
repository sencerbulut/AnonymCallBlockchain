pragma solidity 0.5.1;

////////////////////////////////////////////////////////////
/////admin = 1, officer = 2, user = 3, unregistered = 0/////
////////////////////////////////////////////////////////////


contract PNAPP {

    address admin;

    mapping (address => account) private Accounts;
    mapping (uint => RefAcc) public RefAccounts;
    mapping (address => address[]) public Authorizations;

    event calling(address officerAddress, address userAddress);



    modifier Unregistered(){
        require((Accounts[msg.sender]._role) == 0,"This account is already registered.");
        _;
    }

    modifier onlyAdmin(){
        require((Accounts[msg.sender]._role) == 1,"This action is for ADMIN only.");
        _;
    }

    
    modifier onlyOfficer(){
        require((Accounts[msg.sender]._role) == 2,"This action is for OFFICER only");
        _;
    }
    
    
    modifier onlyUser(){
        require((Accounts[msg.sender]._role) == 3,"This action is for USER only");
        _;
    }
   
    struct RefAcc //reference account
    {
        address _address;
        string _name;
        uint _number;
        uint _ID;
        uint _role;
    }

    struct account
    {   
        address _address;
        string _name;
        uint _number;
        uint _ID;
        uint _role;

    }

    constructor() public{
        admin = msg.sender;
        Accounts[admin]._address = admin;
        Accounts[admin]._name = "Admin";
        Accounts[admin]._number = 1;
        Accounts[admin]._ID = 1;
        Accounts[admin]._role = 1;


        RefAccounts[0] = RefAcc(address(0),"admin reference account",1,1,1);        //admin ref acc
        RefAccounts[1] = RefAcc(address(0),"officer reference account",2,2,2);      //officer ref acc
        RefAccounts[2] = RefAcc(address(0),"user reference account",3,3,3);         //user ref acc
        RefAccounts[3] = RefAcc(address(0),"unregistered reference account",4,4,4); //unregistered ref acc
                                                                                    //unregistered accounts have 0 as their 
                                                                                    //default values in the Accounts mapping
                                                                         

    }

    function userSignIn(string memory name, uint number, uint ID) public Unregistered{
        Accounts[msg.sender] = account(msg.sender, name, number, ID, 3);
    }

    function officerRegistration(address officerAddress, string memory name, uint number, uint ID) public onlyAdmin{
        Accounts[officerAddress] = account(officerAddress, name, number, ID, 2);
    }

    function deleteUser(address userAddress) public onlyAdmin{
        Accounts[userAddress] = account(address(0),"",0,0,0);
    }

    function permitCallAuthorization(address officerAddress, address userAddress) public onlyAdmin{
        Authorizations[officerAddress].push(userAddress);
    }

    function revokeCallAuthorization(address officerAddress, address userAddress) public onlyAdmin{
        for(uint i = 0; i<Authorizations[officerAddress].length; i++){
            if(Authorizations[officerAddress][i] == userAddress){
                Authorizations[officerAddress][i] = address(0);
            }
        }
        
    }

    function callUser(address userAddress) public onlyOfficer{
        
        bool authorized = false;
        for(uint i = 0; i<Authorizations[msg.sender].length; i++){
            
            if(Authorizations[msg.sender][i] == userAddress){
                authorized = true;
                emit calling(msg.sender, userAddress);
            }
            
        }
        require(authorized, "You are not authorized to call this person");

    }
}