pragma solidity ^0.4.18;

import "./MeetupAccessControl.sol";
import "./Members.sol";

/// @title Base contract for Meetup. Holds all common structs, events and base variables.

// Based on
// https://github.com/axiomzen/cryptokitties-bounty/blob/master/contracts/KittyBase.sol
// https://monax.io/docs/solidity/solidity_1_the_five_types_model/
// https://github.com/bokkypoobah/Tokens/blob/master/contracts/FixedSupplyToken.sol
// https://github.com/EOSBetIO/EOSBet-EthereumGamblingContracts/blob/master/contracts/EOSBetBankroll.sol
// https://github.com/bokkypoobah/DecentralisedFutureFundDAO/blob/e72ccf29b9000d236578cfd471a3dbf8a57cd021/contracts/DecentralisedFutureFundDAO.sol

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Interface v1.10
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------
contract BTTSTokenInterface is ERC20Interface {
    uint public constant bttsVersion = 110;

    bytes public constant signingPrefix = "\x19Ethereum Signed Message:\n32";
    bytes4 public constant signedTransferSig = "\x75\x32\xea\xac";
    bytes4 public constant signedApproveSig = "\xe9\xaf\xa7\xa1";
    bytes4 public constant signedTransferFromSig = "\x34\x4b\xcc\x7d";
    bytes4 public constant signedApproveAndCallSig = "\xf1\x6f\x9b\x53";

    event OwnershipTransferred(address indexed from, address indexed to);
    event MinterUpdated(address from, address to);
    event Mint(address indexed tokenOwner, uint tokens, bool lockAccount);
    event MintingDisabled();
    event TransfersEnabled();
    event AccountUnlocked(address indexed tokenOwner);

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);

    // ------------------------------------------------------------------------
    // signed{X} functions
    // ------------------------------------------------------------------------
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveCheck(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function mint(address tokenOwner, uint tokens, bool lockAccount) public returns (bool success);
    function unlockAccount(address tokenOwner) public;
    function disableMinting() public;
    function enableTransfers() public;

    // ------------------------------------------------------------------------
    // signed{X}Check return status
    // ------------------------------------------------------------------------
    enum CheckResult {
        Success,                           // 0 Success
        NotTransferable,                   // 1 Tokens not transferable yet
        AccountLocked,                     // 2 Account locked
        SignerMismatch,                    // 3 Mismatch in signing account
        InvalidNonce,                      // 4 Invalid nonce
        InsufficientApprovedTokens,        // 5 Insufficient approved tokens
        InsufficientApprovedTokensForFees, // 6 Insufficient approved tokens for fees
        InsufficientTokens,                // 7 Insufficient tokens
        InsufficientTokensForFees,         // 8 Insufficient tokens for fees
        OverflowError                      // 9 Overflow error
    }
}


contract MeetupBase is MeetupAccessControl {

    using Members for Members.Data;

    /*** EVENTS ***/

    // @dev The Creation event is fired whenever a new meetup event comes into existence. 
    //      These meetup events are created by event organiser or assistants 
    event MeeupEventCreated(uint64 startTime, uint8 maxCapacity);    
    event BTTSTokenUpdated(address indexed oldBTTSToken, address indexed newBTTSToken);    
    event MemberAdded(address indexed _address, bytes32 _name, bool _governor, uint totalAfter);
    event MemberRemoved(address indexed _address, bytes32 _name, bool _governor, uint totalAfter);


    /*** DATA TYPES ***/

    struct MeetupEvent {
        // The timestamp from the block when the meetup event is created.
        uint64 createTime;

        // The timestamp from the block when the meetup event is scheduled to start.
        uint64 startTime;

        // Capacity of the meeting.
        uint8 maxCapacity;

        // Address of the presenters.
        address[] presenters;

        // Address of people who register for the event.
        // Only the top maxCapacity people will be able to enter.
        // The rest will be on the waiting list.
        address[] registrationList;

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

    // Token incentives
    // uint256 public constant initialTokens = 100;   

    uint8 public constant TOKEN_DECIMALS = 18;
    uint public constant TOKEN_DECIMALSFACTOR = 10 ** uint(TOKEN_DECIMALS); 

    BTTSTokenInterface public bttsToken;    
    bool public initialised;
    Members.Data members;

    uint public tokensForNewGoverningMembers = 200000 * TOKEN_DECIMALSFACTOR; 
    uint public tokensForNewMembers = 1000 * TOKEN_DECIMALSFACTOR; 

    /// @dev An array containing the Meetup struct for all Meetups in existence. 
    MeetupEvent[] public meetupEvents;

    /// @dev An array containing food options
    bytes32[] public foodOptions;
    // Mapping from food name to number of votes
    mapping (bytes32 => uint8) public foodToVotes;


    // // Initialise contract with the owner taking all three roles
    // // These can later be transferred to the right person    
    function Governance() public {
        members.init();
        organiserAddress = msg.sender;
        assistantAddress_1 = msg.sender;
        assistantAddress_2 = msg.sender;
        foodOptions = [bytes32("nothing"), "pizza", "sushi", "salad", "burito", "subway"];
        initialised = false;
    }

    function initSetBTTSToken(address _bttsToken) public onlyOrganiser {
        require(!initialised);
        BTTSTokenUpdated(address(bttsToken), _bttsToken);
        bttsToken = BTTSTokenInterface(_bttsToken);
    }

    function initAddMember(address _address, bytes32 _name, bool _governor) public onlyOrganiser {
        require(!initialised);
        require(bttsToken != address(0));
        members.add(_address, _name, _governor);
        bttsToken.mint(_address, _governor ? tokensForNewGoverningMembers : tokensForNewMembers, false);
    }
    function initRemoveMember(address _address) public onlyOrganiser {
        require(!initialised);
        members.remove(_address);
    }
    function initialisationComplete() public onlyOrganiser {
        require(!initialised);
        require(members.length() != 0);
        initialised = true;
        // transferOwnershipImmediately(address(0));
    }

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
        address[] _presenters,
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
        // require(uint64(_startTime) > uint64(now));

        // Must have at least 1 extra spot
        require(_maxCapacity > _presenters.length);

        address[] memory _registrationList = _presenters;
        bytes32[] memory _registeredUserNames = new bytes32[](_presenters.length);

        // Map address to names
        for (uint i = 0; i < _presenters.length; i++) {            
            _registeredUserNames[i] = getMemberName(_presenters[i]);
        }        

        
        MeetupEvent memory _meetupEvent = MeetupEvent({            
            createTime: uint64(now),
            startTime: _startTime,
            maxCapacity: _maxCapacity,
            presenters: _presenters,
            registrationList: _registrationList,
            registeredUserNames: _registeredUserNames            
        });

        uint256 newMeetupId = meetupEvents.push(_meetupEvent) - 1 ;

        // emit the meetup event creation event
        MeeupEventCreated(_startTime, _maxCapacity);

        return newMeetupId;
    }


	function getPresenters(uint i) public view returns (address[]){
		return meetupEvents[i].presenters;
	}

    function getRegistrationList(uint i) public view returns (address[]){
        return meetupEvents[i].registrationList;
    }

    function getRegisteredUserNames(uint i) public view returns (bytes32[]){
        return meetupEvents[i].registeredUserNames;
    }

    function getFoodOptionCount() public view returns (uint256) {
        return foodOptions.length;
    }

  
    function joinNextMeetup(bytes32 _food)
        public                
        // returns (bool)
    {
        require(members.isMember(msg.sender));        

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

        uint256 _meetupId = meetupEvents.length - 1;
        MeetupEvent storage _meetupEvent = meetupEvents[_meetupId];

        // Can't join a meetup that has already started.
        require(now < _meetupEvent.startTime);        

        // Can't join twice
        for (uint i = 0; i < _meetupEvent.registrationList.length; i++) {
            if (_meetupEvent.registrationList[i] == msg.sender) {
                revert();
            }
        }      

        // bytes32 _userName = addressToUser[msg.sender];
        // bytes32 _userName = users[_userId].userName;
        
        _meetupEvent.registrationList.push(msg.sender);
        _meetupEvent.registeredUserNames.push(getMemberName(msg.sender));

        // deduct deposit
        // addressToPoints[msg.sender] = addressToPoints[msg.sender] - 50;

    }

    function leaveNextMeetup ()
        public           
        // returns (bool)
    {
        // Can't leave a meetup that has already started.
        require(now < _meetupEvent.startTime);        

        // Have to be a registered user
        // require(addressToUser[msg.sender] > 0);        
        require(members.isMember(msg.sender));
        // uint256 _userId = getUserId();
        
        // uint256 _userId = getUserId();

        uint256 _meetupEventId = meetupEvents.length - 1;
        MeetupEvent storage _meetupEvent = meetupEvents[_meetupEventId];

        // Have to be registered to leave
        bool hasJoined = false;
        for (uint i = 0; i < _meetupEvent.registrationList.length; i++) {
            if (_meetupEvent.registrationList[i] == msg.sender) {
                hasJoined = true;

                // can't leave the meetup if there's only one person!
                if (_meetupEvent.registrationList.length > 1) {
                    // shift the last entry to the deleted entry
                    _meetupEvent.registrationList[i] = _meetupEvent.registrationList[_meetupEvent.registrationList.length-1];
                    _meetupEvent.registeredUserNames[i] = _meetupEvent.registeredUserNames[_meetupEvent.registrationList.length-1];

                    // delete the last entry
                    delete(_meetupEvent.registrationList[_meetupEvent.registrationList.length-1]);
                    delete(_meetupEvent.registeredUserNames[_meetupEvent.registrationList.length-1]);

                    // update length
                    _meetupEvent.registrationList.length--;
                    _meetupEvent.registeredUserNames.length--;
                }                
            }
        }      
        require(hasJoined);
    }

    function getMeetupCount () public view returns (uint256) {
        return meetupEvents.length;
    }



    // From Bokky's DFFDAO

    function setBTTSToken(address _bttsToken) internal {
        BTTSTokenUpdated(address(bttsToken), _bttsToken);
        bttsToken = BTTSTokenInterface(_bttsToken);
    }    
    // function setTokensForNewGoverningMembers(uint _newToken) internal {
    //     TokensForNewGoverningMembersUpdated(tokensForNewGoverningMembers, _newToken);
    //     tokensForNewGoverningMembers = _newToken;
    // }
    // function setTokensForNewMembers(uint _newToken) internal {
    //     TokensForNewMembersUpdated(tokensForNewMembers, _newToken);
    //     tokensForNewMembers = _newToken;
    // }
    function addMember(address _address, bytes32 _name, bool _governor) internal {
        members.add(_address, _name, _governor);
        bttsToken.mint(_address, _governor ? tokensForNewGoverningMembers : tokensForNewMembers, false);
    }
    function removeMember(address _address) internal {
        members.remove(_address);
    }

    function numberOfMembers() public view returns (uint) {
        return members.length();
    }
    function getMembers() public view returns (address[]) {
        return members.index;
    }
    function getMemberData(address _address) public view returns (bool _exists, uint _index, bytes32 _name, bool _governor) {
        Members.Member memory member = members.entries[_address];
        return (member.exists, member.index, member.name, member.governor);
    }
    function getMemberName(address _address) public view returns (bytes32 _name) {
        Members.Member memory member = members.entries[_address];
        return (member.name);
    }
    function getMemberByIndex(uint _index) public view returns (address _member) {
        return members.index[_index];
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
