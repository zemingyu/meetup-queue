pragma solidity ^0.4.18;

// import "./MeetupAccessControl.sol";


// Based on https://github.com/axiomzen/cryptokitties-bounty/blob/master/contracts/KittyAccessControl.sol
contract MeetupAccessControl {

  // The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public organiserAddress;
  address public assistantAddress_1;
  address public assistantAddress_2;
  bool paused = false;

  /// Access modifier for organiser-only functionality
  modifier onlyOrganiser() {
      require(msg.sender == organiserAddress);
      _;
  }

  /// Access modifier for organiser-only functionality
  modifier onlyAssistant() {
      require(
        msg.sender == organiserAddress ||
        msg.sender == assistantAddress_1 ||
        msg.sender == assistantAddress_2
      );
      _;
  }

  /// @dev Assigns a new address to act as the assistant. Only available to the current CEO.
  /// @param _newAssistant The address of the new assistant
  function setAssistant_1(address _newAssistant) public onlyAssistant {
      require(_newAssistant != address(0));

      assistantAddress_1 = _newAssistant;
  }

  /// @dev Assigns a new address to act as the assistant. Only available to the current CEO.
  /// @param _newAssistant The address of the new assistant
  function setAssistant_2(address _newAssistant) public onlyAssistant {
      require(_newAssistant != address(0));

      assistantAddress_2 = _newAssistant;
  }


  /// @dev Assigns a new address to act as the organiser. Only available to the current organiser.
  /// @param _newOrganiser The address of the new organiser
  function setOrganiser(address _newOrganiser) public onlyOrganiser {
      require(_newOrganiser != address(0));

      organiserAddress = _newOrganiser;
  }

  /// @dev Modifier to allow actions only when the contract IS NOT paused
  modifier whenNotPaused() {
      require(!paused);
      _;
  }

  /// @dev Modifier to allow actions only when the contract IS paused
  modifier whenPaused {
      require(paused);
      _;
  }

  /// @dev Called by any "assistant" role to pause the contract. Used only when
  ///  a bug or exploit is detected and we need to limit damage.
  function pause() public onlyAssistant whenNotPaused {
      paused = true;
  }

  /// @dev Unpauses the smart contract. Can only be called by the CEO, since
  ///  one reason we may pause the contract is when CFO or COO accounts are
  ///  compromised.
  function unpause() public onlyOrganiser whenPaused {
      // can't unpause if contract was upgraded
      paused = false;
  }

}

/// @title Base contract for Meetup. Holds all common structs, events and base variables.

// Based on
// https://github.com/axiomzen/cryptokitties-bounty/blob/master/contracts/KittyBase.sol
// https://monax.io/docs/solidity/solidity_1_the_five_types_model/

contract MeetupBase is MeetupAccessControl {
    /*** EVENTS ***/

    // @dev The Birth event is fired whenever a new meetup event comes into existence. 
    //      These meetup events are created by event organiser or assistants 
    event Birth(uint64 timeUntilMeetup, uint8 maxCapacity);


    /*** DATA TYPES ***/

    struct Meetup {
        // The timestamp from the block when the meetup event is created.
        uint64 birthTime;

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
    }

    /*** STORAGE ***/

    /// @dev An array containing the Meetup struct for all Meetups in existence. 
    Meetup[] meetups;

    /// @dev A mapping from user address to points
    mapping (address => int256) public userToPoints;

    // Here we store the names. Make it public to automatically generate an
    // accessor function named 'users' that takes a fixed-length string as argument.
    mapping (bytes32 => address) public users;


    // Initialise contract with the owner taking all three roles
    // These can later be transferred to the right person
    function MeetupBase() public {
        organiserAddress = msg.sender;
        assistantAddress_1 = msg.sender;
        assistantAddress_2 = msg.sender;
    }

    // Register the provided name with the caller address.
    // Also, we don't want them to register "" as their name.
    function registerUser(bytes32 name) public {
        require(
            msg.sender == users[name] ||
            msg.sender == organiserAddress ||
            msg.sender == assistantAddress_1 ||
            msg.sender == assistantAddress_2
        );
        
        if(users[name] == 0 && name != ""){
            users[name] = msg.sender;
        }
    }

    // Unregister the provided name with the caller address.
    function unregisterUser(bytes32 name) public {        
        if(users[name] != 0 && name != ""){
            users[name] = 0x0;
        }
    }

    // @param _timeUntilMeetup Time until the scheduled meeting start time
    // @param _maxCapacity Maximum capacity of the meeting.
    // @param _presenters Addresses of presenters.
    function createMeetup (            
        uint64 _timeUntilMeetup,        
        uint8 _maxCapacity,       
        address[] _presenters
    )
        public
        onlyAssistant() 
        returns (uint256)
    {

        address[] memory _registrationList = _presenters;
        
        Meetup memory _meetup = Meetup({            
            birthTime: uint64(now),
            startTime: uint64(now + _timeUntilMeetup),            
            maxCapacity: _maxCapacity,
            presenters: _presenters,
            registrationList: _registrationList
        });

        uint256 newMeetupId = meetups.push(_meetup) - 1 ;

        // emit the birth event
        Birth(_timeUntilMeetup, _maxCapacity);

        return newMeetupId;
    }

    function joinNextMeetup (bytes32 _userName)
        public        
        // returns (bool)
    {
        require(users[_userName] == msg.sender);
        require(users[_userName] != address(0));        

        uint256 _meetupId = meetups.length - 1;
        Meetup storage _meetup = meetups[_meetupId];

        // Can't join a meetup that has already started.
        require(now < _meetup.startTime);        

        // Can't join twice
        for (uint i = 0; i < _meetup.registrationList.length; i++) {
            if (_meetup.registrationList[i] == msg.sender) {
                revert();
            }
        }      

        
        _meetup.registrationList.push(msg.sender);

    }

    function getMeetupCount () public view returns (uint256) {
        return meetups.length;
    }
  

}





// list of meetup members: 
// http://api.meetup.com/BokkyPooBahs-Ethereum-Workshop/members