pragma solidity ^0.4.18;

import "./MeetupAccessControl.sol";

/// @title Base contract for Meetup. Holds all common structs, events and base variables.

// Based on
// https://github.com/axiomzen/cryptokitties-bounty/blob/master/contracts/KittyBase.sol
// https://monax.io/docs/solidity/solidity_1_the_five_types_model/

contract MeetupBase is MeetupAccessControl {
    /*** EVENTS ***/

    // @dev The Creation event is fired whenever a new meetup event comes into existence. 
    //      These meetup events are created by event organiser or assistants 
    event Creation(uint64 startTime, uint8 maxCapacity);


    /*** DATA TYPES ***/

    struct Meetup {
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

    /*** STORAGE ***/

    /// @dev An array containing the Meetup struct for all Meetups in existence. 
    Meetup[] public meetups;

    /// @dev A mapping from user address to points
    mapping (address => uint256) public addressToPoints;

    // Here we store the names. Make it public to automatically generate an
    // accessor function named 'users' that takes a fixed-length string as argument.
    mapping (bytes32 => address) public userToAddress;
    mapping (address => bytes32) public addressToUser;


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
        // require(
        //     msg.sender == userToAddress[name] ||
        //     msg.sender == organiserAddress ||
        //     msg.sender == assistantAddress_1 ||
        //     msg.sender == assistantAddress_2
        // );
        
        if(userToAddress[name] == 0 && name != ""){
            addressToUser[msg.sender] = name;
            userToAddress[name] = msg.sender;            
            addressToPoints[msg.sender] = 100;
        }
    }

    // Deregister the provided name with the caller address.
    // Only user him/herself or assistants can deregister a user
    function deregisterUser(bytes32 name) public onlyAssistant {        
        // require(
        //     msg.sender == users[name] ||
        //     msg.sender == organiserAddress ||
        //     msg.sender == assistantAddress_1 ||
        //     msg.sender == assistantAddress_2
        // );
        if(userToAddress[name] != 0 && name != ""){
            addressToUser[msg.sender] = "";
            userToAddress[name] = 0x0;
        }
    }

    // @param _timeUntilMeetup Time until the scheduled meeting start time
    // @param _maxCapacity Maximum capacity of the meeting.
    // @param _presenters Addresses of presenters.
    function createMeetup (            
        uint64 _startTime,        
        uint8 _maxCapacity,       
        address[] _presenters
    )
        public
        onlyAssistant() 
        returns (uint256)
    {

        // Can't create a meetup in the past
        require(uint64(_startTime) > uint64(now));

        // Must have at least 1 extra spot
        require(_maxCapacity > _presenters.length);

        address[] memory _registrationList = _presenters;
        bytes32[] memory _registeredUserNames = new bytes32[](_presenters.length);

        // Map address to names
        for (uint i = 0; i < _presenters.length; i++) {
            _registeredUserNames[i] = addressToUser[_presenters[i]];
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

        // emit the creation event
        Creation(_startTime, _maxCapacity);

        return newMeetupId;
    }


	function getPresenters(uint i) public view returns (address[]){
		return meetups[i].presenters;
	}

    function getRegistrationList(uint i) public view returns (address[]){
        return meetups[i].registrationList;
    }

    function getRegisteredUserNames(uint i) public view returns (bytes32[]){
        return meetups[i].registeredUserNames;
    }


    function joinNextMeetup ()
        public        
        // returns (bool)
    {
        // require(userToAddress[_userName] == msg.sender);
        // require(userToAddress[_userName] != address(0));        
        require(addressToUser[msg.sender] > 0);

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
        _meetup.registeredUserNames.push(addressToUser[msg.sender]);
        // deduct deposit
        // addressToPoints[msg.sender] = addressToPoints[msg.sender] - 50;

    }

    // function leaveNextMeetup (bytes32 _userName)
    //     public        
    //     // returns (bool)
    // {
    //     require(userToAddress[_userName] == msg.sender);
    //     require(userToAddress[_userName] != address(0));        

    //     uint256 _meetupId = meetups.length - 1;
    //     Meetup storage _meetup = meetups[_meetupId];

    //     // Can't join a meetup that has already started.
    //     require(now < _meetup.startTime);        

    //     // Can't join twice
    //     for (uint i = 0; i < _meetup.registrationList.length; i++) {
    //         if (_meetup.registrationList[i] == msg.sender) {
    //             revert();
    //         }
    //     }      

        
    //     _meetup.registrationList.push(msg.sender);
    //     _meetup.registeredUserNames.push(_userName);
    //     // deduct deposit
    //     // addressToPoints[msg.sender] = addressToPoints[msg.sender] - 50;

    // }

    function getMeetupCount () public view returns (uint256) {
        return meetups.length;
    }
  

}





// list of meetup members: 
// http://api.meetup.com/BokkyPooBahs-Ethereum-Workshop/members
