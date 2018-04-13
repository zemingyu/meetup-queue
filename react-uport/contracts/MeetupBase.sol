pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./MeetupAccessControl.sol";

/// @title Base contract for Meetup. Holds all common structs, events and base variables.

// Based on
// https://github.com/axiomzen/cryptokitties-bounty/blob/master/contracts/KittyBase.sol
// https://monax.io/docs/solidity/solidity_1_the_five_types_model/
// https://github.com/bokkypoobah/Tokens/blob/master/contracts/FixedSupplyToken.sol
// https://github.com/EOSBetIO/EOSBet-EthereumGamblingContracts/blob/master/contracts/EOSBetBankroll.sol

contract ERC20 {
    function totalSupply() constant public returns (uint supply);
    function balanceOf(address _owner) constant public returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) constant public returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract MeetupBase is ERC20, MeetupAccessControl {
    using SafeMath for *;

    /*** EVENTS ***/

    // @dev The Creation event is fired whenever a new meetup event comes into existence. 
    //      These meetup events are created by event organiser or assistants 
    event MeeupEventCreated(uint64 startTime, uint8 maxCapacity);
    event UserCreated(uint64 userCreateTime, uint256 userId, bytes32 userName);


    /*** DATA TYPES ***/

    struct Meetup {
        // The timestamp from the block when the meetup event is created.
        uint64 createTime;

        // The timestamp from the block when the meetup event is scheduled to start.
        uint64 startTime;

        // Capacity of the meeting.
        uint8 maxCapacity;

        // User ID of the presenters.
        uint256[] presenters;

        // User ID of people who register for the event.
        // Only the top maxCapacity people will be able to enter.
        // The rest will be on the waiting list.
        uint256[] registrationList;

        bytes32[] registeredUserNames;
    }

    struct User {
        uint64 userCreateTime;
        address userAddress;
        bytes32 userName;
        // uint256 userPoints;
        bool hasDeregistered;                
    }

    /*** STORAGE ***/

    // constants for ERC20 standard
    string public constant name = "BokkyPooBahs Ethereum Workshop Tokens";
    string public constant symbol = "BPB";
    uint8 public constant decimals = 18;

    // variable total supply
    uint256 public totalSupply;

    // mapping to store tokens
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    // Token incentives
    uint256 public constant initialTokens = 100;   
    

    /// @dev An array containing the Meetup struct for all Meetups in existence. 
    Meetup[] public meetups;
    User[] public users;

    /// @dev A mapping from user address to points
    // mapping (address => uint256) public addressToPoints;

    mapping (bytes32 => address) public userToAddress;
    mapping (address => bytes32) public addressToUser;

    /// @dev An array containing food options
    bytes32[] public foodOptions;
    // Mapping from food name to number of votes
    mapping (bytes32 => uint8) public foodToVotes;


    // Initialise contract with the owner taking all three roles
    // These can later be transferred to the right person
    function MeetupBase() public {
        organiserAddress = msg.sender;
        assistantAddress_1 = msg.sender;
        assistantAddress_2 = msg.sender;
        foodOptions = [bytes32("nothing"), "pizza", "sushi", "salad", "burito", "subway"];        

        // start with 0, issue 100 tokens to every new user
        totalSupply = 0;
    }


    function createUser(bytes32 _userName) public returns (uint256) {
        require(msg.sender != 0 && _userName != "");

        // Make sure the user is new
        bool isNewUser = true;        
        for (uint i = 0; i < users.length; i++) {
            if (users[i].userAddress == msg.sender) {
                isNewUser = false;          
            }
        }
        require(isNewUser);

        User memory _user = User({
            userCreateTime: uint64(now),
            userAddress: msg.sender,
            userName: _userName,
            // userPoints: 100,
            hasDeregistered: false  
        });

        // Issue ERC20 token
        balances[msg.sender] = initialTokens;
        totalSupply = SafeMath.add(totalSupply, initialTokens);

        uint256 _userId = users.push(_user) - 1;
        UserCreated(uint64(now), _userId, _userName);
        return _userId;
    }

    function deregisterUser(uint256 _id) public returns (bool) {
        require(users[_id].userAddress == msg.sender);        
        users[_id].hasDeregistered = true;
    }

    /// @notice Returns all the relevant information about a specific user.
    /// @param _id The ID of the user of interest.
    function getUser(uint256 _id)
        public
        view
        returns (
        uint64 userCreateTime,
        address userAddress,
        bytes32 userName,
        // uint256 userPoints,
        bool hasDeregistered
    ) {
        User storage user = users[_id];
        
        userCreateTime = user.userCreateTime;
        userAddress = user.userAddress;
        userName = user.userName;
        // userPoints = user.userPoints;
        hasDeregistered = user.hasDeregistered;        
    }

    // // Register the provided name with the caller address.
    // // Also, we don't want them to register "" as their name.
    // function registerUser(bytes32 name) public {
    //     // require(
    //     //     msg.sender == userToAddress[name] ||
    //     //     msg.sender == organiserAddress ||
    //     //     msg.sender == assistantAddress_1 ||
    //     //     msg.sender == assistantAddress_2
    //     // );
        
    //     if(userToAddress[name] == 0 && name != ""){
    //         addressToUser[msg.sender] = name;
    //         userToAddress[name] = msg.sender;            
    //         // addressToPoints[msg.sender] = 100;
    //     }
    // }

    // // Deregister the provided name with the caller address.
    // // Only user him/herself or assistants can deregister a user
    // function deregisterUser(bytes32 name) public onlyAssistant {        
    //     // require(
    //     //     msg.sender == users[name] ||
    //     //     msg.sender == organiserAddress ||
    //     //     msg.sender == assistantAddress_1 ||
    //     //     msg.sender == assistantAddress_2
    //     // );
    //     if(userToAddress[name] != 0 && name != ""){
    //         addressToUser[msg.sender] = "";
    //         userToAddress[name] = 0x0;
    //     }
    // }

    function addFoodOption(bytes32 _food) public onlyAssistant {
        require(_food != '');

        // Can't add the same food twice
        for (uint i = 0; i < foodOptions.length; i++) {
            if (foodOptions[i] == _food) {
                revert();
            }
        }

        foodOptions.push(_food);
    }

    function removeFoodOption(bytes32 _food) public onlyAssistant {
        require(_food != '' && _food != 'nothing');

        // Has to be in the food option list to be removed
        bool isListedFood = false;
        for (uint i = 0; i < foodOptions.length; i++) {
            if (foodOptions[i] == _food) {
                isListedFood = true;

                // can't remove the food option if there's only one option left!
                if (foodOptions.length > 1) {
                    // shift the last entry to the deleted entry
                    foodOptions[i] = foodOptions[foodOptions.length-1];                    

                    // delete the last entry
                    delete(foodOptions[foodOptions.length-1]);                    

                    // update length
                    foodOptions.length--;                    
                }                
            }
        }      
        require(isListedFood);
    }

    /// @dev Computes the winning food option taking all
    /// previous votes into account.
    function getWinningFood() public view
            returns (bytes32 winningFood_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < foodOptions.length; p++) {
            if (foodOptions[p] != "nothing" &&
                foodToVotes[foodOptions[p]] > winningVoteCount) {
                winningVoteCount = foodToVotes[foodOptions[p]];
                winningFood_ = foodOptions[p];
            }
        }
    }

    /// @dev Clear food votes in preparation for the next round of voting    
    function clearFoodVotes() public onlyAssistant             
    {        
        for (uint p = 0; p < foodOptions.length; p++) {
            foodToVotes[foodOptions[p]] = 0;            
        }
    }

    // @param _timeUntilMeetup Time until the scheduled meeting start time
    // @param _maxCapacity Maximum capacity of the meeting.
    // @param _presenters Addresses of presenters.
    // @param _food food voted by the creator
    function createMeetup (            
        uint64 _startTime,        
        uint8 _maxCapacity,       
        uint256[] _presenters,
        bytes32 _food
    )
        public
        onlyAssistant() 
        returns (uint256)
    {
        // Check if the food option is valid
        bool isValidFood = false;
        require(_food != '');
        for (uint j = 0; j < foodOptions.length; j++) {
            if (foodOptions[j] == _food) {
                isValidFood = true;
            }
        }
        require(isValidFood);

        foodToVotes[_food] += 1;


        // Can't create a meetup in the past
        require(uint64(_startTime) > uint64(now));

        // Must have at least 1 extra spot
        require(_maxCapacity > _presenters.length);

        uint256[] memory _registrationList = _presenters;
        bytes32[] memory _registeredUserNames = new bytes32[](_presenters.length);

        // Map address to names
        for (uint i = 0; i < _presenters.length; i++) {
            // _registeredUserNames[i] = addressToUser[_presenters[i]];
            _registeredUserNames[i] = users[_presenters[i]].userName;
        }        

        
        Meetup memory _meetup = Meetup({            
            createTime: uint64(now),
            startTime: uint64(_startTime),
            maxCapacity: _maxCapacity,
            presenters: _presenters,
            registrationList: _registrationList,
            registeredUserNames: _registeredUserNames            
        });

        uint256 newMeetupId = meetups.push(_meetup) - 1 ;

        // emit the meetup event creation event
        MeeupEventCreated(_startTime, _maxCapacity);

        return newMeetupId;
    }


	function getPresenters(uint i) public view returns (uint256[]){
		return meetups[i].presenters;
	}

    function getRegistrationList(uint i) public view returns (uint256[]){
        return meetups[i].registrationList;
    }

    function getRegisteredUserNames(uint i) public view returns (bytes32[]){
        return meetups[i].registeredUserNames;
    }

    function getFoodOptionCount() public view returns (uint256) {
        return foodOptions.length;
    }


    function getUserId() internal view returns (uint256) {
      bool isValidUser = false;
      uint256 userId;
      for (uint i = 0; i < users.length; i++) {
        if (users[i].userAddress == msg.sender && 
          users[i].hasDeregistered == false) {
          isValidUser = true;
          userId = i;
        }
      }  
      require(isValidUser);

      return userId;
    }
    
    function joinNextMeetup(bytes32 _food)
        public                
        // returns (bool)
    {
        // require(userToAddress[_userName] == msg.sender);
        // require(userToAddress[_userName] != address(0));        
        // require(addressToUser[msg.sender] > 0);        
        uint256 _userId = getUserId();

        // Check if the food option is valid
        bool isValidFood = false;
        require(_food != '');
        for (uint j = 0; j < foodOptions.length; j++) {
            if (foodOptions[j] == _food) {
                isValidFood = true;
            }
        }
        require(isValidFood);

        foodToVotes[_food] += 1;

        uint256 _meetupId = meetups.length - 1;
        Meetup storage _meetup = meetups[_meetupId];

        // Can't join a meetup that has already started.
        require(now < _meetup.startTime);        

        // Can't join twice
        for (uint i = 0; i < _meetup.registrationList.length; i++) {
            if (_meetup.registrationList[i] == _userId) {
                revert();
            }
        }      

        // bytes32 _userName = addressToUser[msg.sender];
        bytes32 _userName = users[_userId].userName;
        _meetup.registrationList.push(_userId);
        _meetup.registeredUserNames.push(_userName);

        // deduct deposit
        // addressToPoints[msg.sender] = addressToPoints[msg.sender] - 50;

    }

    function leaveNextMeetup ()
        public           
        // returns (bool)
    {
        // Can't leave a meetup that has already started.
        require(now < _meetup.startTime);        

        // Have to be a registered user
        // require(addressToUser[msg.sender] > 0);        
        uint256 _userId = getUserId();

        uint256 _meetupId = meetups.length - 1;
        Meetup storage _meetup = meetups[_meetupId];

        // Have to be registered to leave
        bool hasJoined = false;
        for (uint i = 0; i < _meetup.registrationList.length; i++) {
            if (_meetup.registrationList[i] == _userId) {
                hasJoined = true;

                // can't leave the meetup if there's only one person!
                if (_meetup.registrationList.length > 1) {
                    // shift the last entry to the deleted entry
                    _meetup.registrationList[i] = _meetup.registrationList[_meetup.registrationList.length-1];
                    _meetup.registeredUserNames[i] = _meetup.registeredUserNames[_meetup.registrationList.length-1];

                    // delete the last entry
                    delete(_meetup.registrationList[_meetup.registrationList.length-1]);
                    delete(_meetup.registeredUserNames[_meetup.registrationList.length-1]);

                    // update length
                    _meetup.registrationList.length--;
                    _meetup.registeredUserNames.length--;
                }                
            }
        }      
        require(hasJoined);
    }

    function getMeetupCount () public view returns (uint256) {
        return meetups.length;
    }


    ///////////////////////////////
    // BASIC ERC20 TOKEN OPERATIONS
    ///////////////////////////////

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return totalSupply  - balances[address(0)];
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
  

}





// list of meetup members: 
// http://api.meetup.com/BokkyPooBahs-Ethereum-Workshop/members
