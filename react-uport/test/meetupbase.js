
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

contract('MeetupBase', function([admin, organiser, assistant1, assistant2, 
                                 presenter1, attendee1, anyone]) {
  let meetupBaseInstance;

  beforeEach('setup contract for each test', async function () {
    meetupBaseInstance = await MeetupBase.new(admin);    
    await meetupBaseInstance.setOrganiser(organiser, {from: admin});    
    await meetupBaseInstance.setAssistant_1(assistant1, {from: admin});    
    await meetupBaseInstance.setAssistant_2(assistant2, {from: admin});    
  });

  describe('Initial meetup setup', async () => {
    it('has initial organiser', async () => {
      assert.equal(await meetupBaseInstance.organiserAddress(), organiser);
    });    

    it('has initial assistant1', async () => {
      assert.equal(await meetupBaseInstance.assistantAddress_1(), assistant1);
    });    

    it('has initial assistant2', async () => {
      assert.equal(await meetupBaseInstance.assistantAddress_2(), assistant2);
    });
  });

    
  describe('Initial meetup setup', () => {
    it('can register Zeming Yu', async () => {
      await meetupBaseInstance.registerUser("Zeming Yu", {from: admin});      
      assert.equal(await meetupBaseInstance.users.call("Zeming Yu"), admin);
    });

    it('can register BokkyPooBah', async () => {
      await meetupBaseInstance.registerUser("BokkyPooBah", {from: organiser});      
      assert.equal(await meetupBaseInstance.users.call("BokkyPooBah"), organiser);
    });

    it('can register David Lim', async () => {
      await meetupBaseInstance.registerUser("David Lim", {from: assistant1});      
      assert.equal(await meetupBaseInstance.users.call("David Lim"), assistant1);
    });

    it('can register James Zaki', async () => {
      await meetupBaseInstance.registerUser("James Zaki", {from: assistant2});      
      assert.equal(await meetupBaseInstance.users.call("James Zaki"), assistant2);
    });

    it('can register Sanjev Sunder', async () => {
      await meetupBaseInstance.registerUser("Sanjev Sunder", {from: presenter1});      
      assert.equal(await meetupBaseInstance.users.call("Sanjev Sunder"), presenter1);
    });

    it('can register Andrew', async () => {      
      await meetupBaseInstance.registerUser("Andrew", {from: attendee1});      
      assert.equal(await meetupBaseInstance.users.call("Andrew"), attendee1);
    });

    it('allows assistants to deregister Zeming Yu', async () => {
      await meetupBaseInstance.deregisterUser("Zeming Yu", {from: organiser});      
      assert.equal(await meetupBaseInstance.users.call("Zeming Yu"), 0x0);
    });
  });

});




// var MeetupBase = artifacts.require("./MeetupBase.sol");
// contract('MeetupBase', function(accounts) {

//   it("...can register user.", function() {
//     return MeetupBase.deployed().then(function(instance) {
//       meetupBaseInstance = instance;

//       return meetupBaseInstance.registerUser("Alice", {from: accounts[0]});
//     }).then(function() {
//       return meetupBaseInstance.users.call("Alice")
//     }).then(function(reg_addr) {
//       assert.equal(reg_addr, accounts[0], "The user 'Alice' was not registered.");
//     });
//   });

// });
