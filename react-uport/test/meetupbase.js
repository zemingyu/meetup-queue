// const Web3 = require('web3');
// const web3 = new Web3(ganache.provider());
const moment = require('moment');

var MeetupBase = artifacts.require("./MeetupBase.sol");
var meetupBaseInstance;


const timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], // 86400 is num seconds in day
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}
//To add some time, just use this:
// await timeTravel(86400 * 3) //3 days later


// Convert string to datetime
// datetimeStr must be in this format: '17-09-2013 10:08'
const parseDateTime = function (dateTimeStr) {
  var dateTimeParts = dateTimeStr.split(' '),
      timeParts = dateTimeParts[1].split(':'),
      dateParts = dateTimeParts[0].split('-'),
      dateTime;
  dateTime = new Date(dateParts[2], parseInt(dateParts[1], 10) - 1, dateParts[0], timeParts[0], timeParts[1]);
  return dateTime.getTime()/1000; // convert to seconds
}


const getMeetupRegisterdUsers = async () => {

  // console.log("Registered User ID's: ")

  for (i = 0; i < _registrationList.length; i++) { 
    _userId = await _registrationList[i].toNumber();
    _userAttr = await getUserHelper(_userId);
    console.log(_userAttr['userName'] + ": " + _userAttr['userTokens']);    
  }

  // console.log("Registered Users Names: ")            
  // console.log(_registeredUserNames.map(
  //   (x) => {return web3.toAscii(x).replace(/\u0000/g, '')}));      
  // // console.log(_registeredUserNames.map(
  // //   (x) => {return web3.toUtf8(x)}));      

}

const getUserHelper = async (id) => {
  let attrs = await meetupBaseInstance.getUser(id);
  let _userTokens = (await meetupBaseInstance.balanceOf(attrs[1])).toNumber();
  return {
    userCreateTime: moment.unix(attrs[0].toNumber()).format('dddd, MMMM Do, YYYY h:mm:ss A'),
    userAddress: attrs[1],
    userName: web3.toAscii(attrs[2]).replace(/\u0000/g, ''),
    userTokens: _userTokens,
    hasDeregistered: attrs[3]
  };    
}

contract('MeetupBase', function([admin, organiser, assistant1, assistant2, 
                                 presenter1, attendee1, anyone]) {
  
  beforeEach('setup contract for each test', async function () {
    // transfer roles
    meetupBaseInstance = await MeetupBase.new();    
    await meetupBaseInstance.setOrganiser(organiser, {from: admin});    
    await meetupBaseInstance.setAssistant_1(assistant1, {from: admin});    
    await meetupBaseInstance.setAssistant_2(assistant2, {from: admin});    

    // create users
    await meetupBaseInstance.createUser("Zeming Yu", {from: admin});
    await meetupBaseInstance.createUser("BokkyPooBah", {from: organiser});      
    await meetupBaseInstance.createUser("David Lim", {from: assistant1});      
    await meetupBaseInstance.createUser("James Zaki", {from: assistant2});      
    await meetupBaseInstance.createUser("Sanjev Sunder", {from: presenter1});      
    await meetupBaseInstance.createUser("Andrew", {from: attendee1});         

    // setup an event for testing
    dateTimeStr = '22-06-2019 14:16';

    beforeCount = await meetupBaseInstance.getMeetupCount();
    await meetupBaseInstance.createMeetup(parseDateTime(dateTimeStr), 10, [1, 4], "pizza", {from: organiser});
    afterCount = await meetupBaseInstance.getMeetupCount();
    assert.equal(beforeCount.toNumber(), afterCount.toNumber()-1);

  });

  describe('Initial meetup setup', async () => {
    it('has initial organiser and assistants', async () => {
      assert.equal(await meetupBaseInstance.organiserAddress(), organiser);
      assert.equal(await meetupBaseInstance.assistantAddress_1(), assistant1);
      assert.equal(await meetupBaseInstance.assistantAddress_2(), assistant2);
    });

    it('can deregister a user', async () => {
      userAttr = await getUserHelper(5);      
      assert.equal(userAttr.userName, "Andrew");
      assert.equal(userAttr.hasDeregistered, false);
      await meetupBaseInstance.deregisterUser(5, {from: attendee1});      
      userAttr = await getUserHelper(5);      
      assert.equal(userAttr.hasDeregistered, true);            
      console.log(userAttr);
    })

  });


  describe('Food option admin', async () => {
    it('can display food options', async () => {
      foodOptionCount = await meetupBaseInstance.getFoodOptionCount.call();      

      var expectedFoodOptions = ['nothing', 'pizza', 'sushi', 'salad', 'burito', 'subway'];
      for (i = 0; i < foodOptionCount; i++) { 
        // console.log(await meetupBaseInstance.foodOptions(i));        
        // console.log(web3.toAscii(await meetupBaseInstance.foodOptions(i)));
        assert.equal(web3.toAscii(await meetupBaseInstance.foodOptions(i)).replace(/\u0000/g, ''), 
          expectedFoodOptions[i]);
      }      
    });

    it('can add food options', async () => {     
      await meetupBaseInstance.addFoodOption("noodle", {from: organiser});    

      foodOptionCount = await meetupBaseInstance.getFoodOptionCount.call();      
      var expectedFoodOptions = ['nothing', 'pizza', 'sushi', 'salad', 'burito', 'subway', 'noodle'];
      for (i = 0; i < foodOptionCount; i++) { 
        assert.equal(web3.toAscii(await meetupBaseInstance.foodOptions(i)).replace(/\u0000/g, ''), 
          expectedFoodOptions[i]);
      }      
    });

    it('can remove food options', async () => {     
      await meetupBaseInstance.removeFoodOption("pizza", {from: organiser});    

      foodOptionCount = await meetupBaseInstance.getFoodOptionCount.call();      
      var expectedFoodOptions = ['nothing', 'subway', 'sushi', 'salad', 'burito'];
      for (i = 0; i < foodOptionCount; i++) { 
        assert.equal(web3.toAscii(await meetupBaseInstance.foodOptions(i)).replace(/\u0000/g, ''), 
          expectedFoodOptions[i]);
      }      
    });
  });


  describe('Meetup events', async () => {

    it('can create 1 meetup event', async () => {
      dateTimeStr = '22-06-2019 14:16';
      dateTimeStr2 = moment.unix(parseDateTime(dateTimeStr)).format('dddd, MMMM Do, YYYY h:mm:ss A');

      // console.log(parseDateTime(dateTimeStr));
      // console.log(dateTimeStr2);
      // console.log(parseDateTime('22-03-2018 10:15').toString());// This only works in a webpage

      beforeCount = await meetupBaseInstance.getMeetupCount();
      // await timeTravel(86400 * 1); //9 days later
      // await web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});
      await meetupBaseInstance.createMeetup(parseDateTime(dateTimeStr), 3, [0, 1], "pizza", {from: organiser});
      afterCount = await meetupBaseInstance.getMeetupCount();
      assert.equal(beforeCount.toNumber(), afterCount.toNumber()-1);

      // console.log(await meetupBaseInstance.meetups.call(0))
    });

    it('forbids setting up a meetup event in the past', async () => {
      dateTimeStr = '22-03-2018 14:16';
      dateTimeStr2 = moment.unix(parseDateTime(dateTimeStr)).format('dddd, MMMM Do, YYYY h:mm:ss A');

      try {
        await meetupBaseInstance.createMeetup(parseDateTime(dateTimeStr), 3, [0, 1], "pizza", {from: organiser});
        assert(false);
      } catch (err) {
        assert(err);
      }      
    });

    it('allows people to join the meetup event', async () => {
      // mt = (await meetupBaseInstance.meetups.call(0));
      // console.log(mt);

      // _presenters = (await meetupBaseInstance.getPresenters.call(0));
      // console.log("List of presenters: " + _presenters);

      // Before registering users
      console.log("BEFORE...")
      _registrationList = (await meetupBaseInstance.getRegistrationList.call(0));
      _registeredUserNames = (await meetupBaseInstance.getRegisteredUserNames.call(0));
      getMeetupRegisterdUsers(0);

      // Register users
      await meetupBaseInstance.joinNextMeetup("pizza", {from: admin});
      // await meetupBaseInstance.joinNextMeetup({from: anyone}); //Fails as anyone is not registered

      // After registering users
      console.log("AFTER...")
      _registrationList = (await meetupBaseInstance.getRegistrationList.call(0));
      _registeredUserNames = (await meetupBaseInstance.getRegisteredUserNames.call(0));
      getMeetupRegisterdUsers(0);
      
    });

    it('allows people to join and leave the meetup event', async () => {
      // Before registering users
      console.log("BEFORE...")
      _registrationList = (await meetupBaseInstance.getRegistrationList.call(0));
      _registeredUserNames = (await meetupBaseInstance.getRegisteredUserNames.call(0));
      getMeetupRegisterdUsers(0);

      // Register users
      await meetupBaseInstance.joinNextMeetup("pizza", {from: admin});
      // await meetupBaseInstance.joinNextMeetup({from: anyone}); //Fails as anyone is not registered

      // After registering users
      console.log("AFTER Joining...")
      _registrationList = (await meetupBaseInstance.getRegistrationList.call(0));
      _registeredUserNames = (await meetupBaseInstance.getRegisteredUserNames.call(0));
      getMeetupRegisterdUsers(0);

      // Leave
      await meetupBaseInstance.leaveNextMeetup({from: admin});
      await meetupBaseInstance.leaveNextMeetup({from: organiser});
      // await meetupBaseInstance.leaveNextMeetup({from: presenter1}); //last person is not allowed to leave
      
      
      // After leaving
      console.log("AFTER Leaving...")
      _registrationList = (await meetupBaseInstance.getRegistrationList.call(0));
      _registeredUserNames = (await meetupBaseInstance.getRegisteredUserNames.call(0));
      getMeetupRegisterdUsers(0);

      
    });

    it('can find the winning food option', async () => {
      await meetupBaseInstance.joinNextMeetup("nothing", {from: admin});
      // await meetupBaseInstance.joinNextMeetup("pizza", {from: organiser}); //Can't join twice
      await meetupBaseInstance.joinNextMeetup("sushi", {from: assistant1});
      await meetupBaseInstance.joinNextMeetup("sushi", {from: assistant2});
      await meetupBaseInstance.joinNextMeetup("nothing", {from: attendee1});

      winningFood = web3.toAscii(await meetupBaseInstance.getWinningFood({from: admin})).replace(/\u0000/g, '');
      console.log(winningFood);

    });

    it('can clear food option votes to prepare for the next round of voting', async () => {
      await meetupBaseInstance.joinNextMeetup("pizza", {from: admin});
      winningFood = web3.toAscii(await meetupBaseInstance.getWinningFood({from: admin})).replace(/\u0000/g, '');
      console.log("1st round winner: " + winningFood);

      await meetupBaseInstance.clearFoodVotes({from: organiser});

      await meetupBaseInstance.joinNextMeetup("sushi", {from: assistant1});
      await meetupBaseInstance.joinNextMeetup("sushi", {from: assistant2});
      await meetupBaseInstance.joinNextMeetup("nothing", {from: attendee1});

      winningFood = web3.toAscii(await meetupBaseInstance.getWinningFood({from: admin})).replace(/\u0000/g, '');
      console.log("2nd round winner: " + winningFood);
    });

  });
});




  // describe('Initial meetup setup', () => {
  //   it('can register Zeming Yu', async () => {
  //     await meetupBaseInstance.registerUser("Zeming Yu", {from: admin});      
  //     assert.equal(await meetupBaseInstance.userToAddress.call("Zeming Yu"), admin);
  //   });

  //   it('can register BokkyPooBah', async () => {
  //     await meetupBaseInstance.registerUser("BokkyPooBah", {from: organiser});      
  //     assert.equal(await meetupBaseInstance.userToAddress.call("BokkyPooBah"), organiser);
  //   });

  //   it('can register David Lim', async () => {
  //     await meetupBaseInstance.registerUser("David Lim", {from: assistant1});      
  //     assert.equal(await meetupBaseInstance.userToAddress.call("David Lim"), assistant1);
  //   });

  //   it('can register James Zaki', async () => {
  //     await meetupBaseInstance.registerUser("James Zaki", {from: assistant2});      
  //     assert.equal(await meetupBaseInstance.userToAddress.call("James Zaki"), assistant2);
  //   });

  //   it('can register Sanjev Sunder', async () => {
  //     await meetupBaseInstance.registerUser("Sanjev Sunder", {from: presenter1});      
  //     assert.equal(await meetupBaseInstance.userToAddress.call("Sanjev Sunder"), presenter1);
  //   });

  //   it('can register Andrew', async () => {      
  //     await meetupBaseInstance.registerUser("Andrew", {from: attendee1});      
  //     assert.equal(await meetupBaseInstance.userToAddress.call("Andrew"), attendee1);
  //   });

  //   it('allows assistants to deregister Zeming Yu', async () => {
  //     await meetupBaseInstance.deregisterUser("Zeming Yu", {from: organiser});      
  //     assert.equal(await meetupBaseInstance.userToAddress.call("Zeming Yu"), 0x0);
  //   });
  // });


// var MeetupBase = artifacts.require("./MeetupBase.sol");
// contract('MeetupBase', function(accounts) {

//   it("...can register user.", function() {
//     return MeetupBase.deployed().then(function(instance) {
//       meetupBaseInstance = instance;

//       return meetupBaseInstance.registerUser("Alice", {from: accounts[0]});
//     }).then(function() {
//       return meetupBaseInstance.userToAddress.call("Alice")
//     }).then(function(reg_addr) {
//       assert.equal(reg_addr, accounts[0], "The user 'Alice' was not registered.");
//     });
//   });

// });
