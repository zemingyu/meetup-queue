pragma solidity ^0.4.19;

import "./MeetupAccessControl.sol";

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

    // Register the provided name with the caller address.
    // Also, we don't want them to register "" as their name.
    function registerUser(bytes32 name) public {
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

        address[] memory _registrationList;
        
        Meetup memory _meetup = Meetup({            
            birthTime: uint64(now),
            startTime: uint64(now + _timeUntilMeetup),            
            maxCapacity: _maxCapacity,
            presenters: _presenters,
            registrationList: _registrationList
        });

        uint256 newMeetupId = meetups.push(_meetup) - 1 ;

        // emit the birth event
        emit Birth(_timeUntilMeetup, _maxCapacity);

        return newMeetupId;
    }

    function joinNextMeetup (bytes32 _userName)
        public        
        // returns (bool)
    {
        require(users[_userName] == msg.sender);
        require(users[_userName] != address(0));        

        uint256 _meetupId = meetups.length -1;
        Meetup memory _meetup = meetups[_meetupId];

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
  

}





// list of meetup members: 
// http://api.meetup.com/BokkyPooBahs-Ethereum-Workshop/members