// const Web3 = require('web3');
// const web3 = new Web3(ganache.provider());
const moment = require('moment');

var MeetupBase = artifacts.require("./MeetupBase.sol");


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


contract('MeetupBase', function([admin, organiser, assistant1, assistant2, 
                                 presenter1, attendee1, anyone]) {
  let meetupBaseInstance;

  beforeEach('setup contract for each test', async function () {
    // transfer roles
    meetupBaseInstance = await MeetupBase.new();    
    await meetupBaseInstance.setOrganiser(organiser, {from: admin});    
    await meetupBaseInstance.setAssistant_1(assistant1, {from: admin});    
    await meetupBaseInstance.setAssistant_2(assistant2, {from: admin});    

    // register everyone
    await meetupBaseInstance.registerUser("Zeming Yu", {from: admin});      
    await meetupBaseInstance.registerUser("BokkyPooBah", {from: organiser});      
    await meetupBaseInstance.registerUser("David Lim", {from: assistant1});      
    await meetupBaseInstance.registerUser("James Zaki", {from: assistant2});      
    await meetupBaseInstance.registerUser("Sanjev Sunder", {from: presenter1});      
    await meetupBaseInstance.registerUser("Andrew", {from: attendee1});      
    // await meetupBaseInstance.registerUser("Anyone", {from: anyone});      

    // let balance = await web3.eth.getBalance(admin);    
    // console.log(web3.fromWei(balance.toNumber(), 'ether'));

  });

  describe('Initial meetup setup', async () => {
    it('has initial organiser and assistants', async () => {
      assert.equal(await meetupBaseInstance.organiserAddress(), organiser);
      assert.equal(await meetupBaseInstance.assistantAddress_1(), assistant1);
      assert.equal(await meetupBaseInstance.assistantAddress_2(), assistant2);
    });

    it('can convert user name to address', async () => {
      assert.equal(await meetupBaseInstance.userToAddress("Zeming Yu"), admin);      
    });

    it('can convert address to user name', async () => {
      // assert.equal(await meetupBaseInstance.userToAddress("Zeming Yu"), admin);      
      hexUserName = await meetupBaseInstance.addressToUser(admin);
      strUserName = web3.toAscii(hexUserName);
      // console.log(hexUserName);
      console.log(strUserName);      
    });


  });


  describe('Meetup events', async () => {

    // it('can create 1 meetup event', async () => {
    //   dateTimeStr = '22-04-2018 14:16';
    //   dateTimeStr2 = moment.unix(parseDateTime(dateTimeStr)).format('dddd, MMMM Do, YYYY h:mm:ss A');

    //   console.log(parseDateTime(dateTimeStr));
    //   console.log(dateTimeStr2);
    //   // console.log(parseDateTime('22-03-2018 10:15').toString());// This only works in a webpage

    //   beforeCount = await meetupBaseInstance.getMeetupCount();
    //   // await timeTravel(86400 * 1); //9 days later
    //   // await web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0});
    //   await meetupBaseInstance.createMeetup(parseDateTime(dateTimeStr), 3, [organiser, presenter1], {from: organiser});
    //   afterCount = await meetupBaseInstance.getMeetupCount();
    //   assert.equal(beforeCount.toNumber(), afterCount.toNumber()-1);

    //   console.log(await meetupBaseInstance.meetups.call(0))
    // });

    // it('can create 2 meetup events', async () => {
    //   // setup an event in 1 week's time and another in 2 weeks' time
    //   beforeCount = await meetupBaseInstance.getMeetupCount();
    //   await meetupBaseInstance.createMeetup(60*60*24*7, 3, [organiser, presenter1], {from: organiser});
    //   await meetupBaseInstance.createMeetup(60*60*24*14, 3, [assistant1, assistant2], {from: assistant1});
    //   afterCount = await meetupBaseInstance.getMeetupCount();
    //   assert.equal(beforeCount.toNumber(), afterCount.toNumber()-2);
    // });

    it('allows people to join the meetup event', async () => {
      // setup an event in 1 week's time
      dateTimeStr = '22-04-2018 14:16';

      beforeCount = await meetupBaseInstance.getMeetupCount();
      await meetupBaseInstance.createMeetup(parseDateTime(dateTimeStr), 4, [organiser, presenter1], {from: organiser});
      afterCount = await meetupBaseInstance.getMeetupCount();
      assert.equal(beforeCount.toNumber(), afterCount.toNumber()-1);

      // mt = (await meetupBaseInstance.meetups.call(0));
      // console.log(mt);

      // _presenters = (await meetupBaseInstance.getPresenters.call(0));
      // console.log("List of presenters: " + _presenters);


      // Before registering users
      _registrationList = (await meetupBaseInstance.getRegistrationList.call(0));
      _registeredUserNames = (await meetupBaseInstance.getRegisteredUserNames.call(0));

      console.log("BEFORE...")
      console.log("Registered User Addresses: ")
      console.log(_registrationList);
      console.log("Registered Users Names: ")            
      console.log(_registeredUserNames.map(
        (x) => {return web3.toAscii(x).replace(/\u0000/g, '')}));      
      // console.log(_registeredUserNames.map(
      //   (x) => {return web3.toUtf8(x)}));      


      // Register users
      await meetupBaseInstance.joinNextMeetup({from: admin});
      // await meetupBaseInstance.joinNextMeetup({from: anyone}); //Fails as anyone is not registered

      // After registering users
      _registrationList = (await meetupBaseInstance.getRegistrationList.call(0));
      _registeredUserNames = (await meetupBaseInstance.getRegisteredUserNames.call(0));

      console.log("AFTER...")
      console.log("Registered User Addresses: ")
      console.log(_registrationList);
      console.log("Registered Users Names: ")            
      console.log(_registeredUserNames.map(
        (x) => {return web3.toAscii(x).replace(/\u0000/g, '')}));      
      
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
