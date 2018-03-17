
var MeetupBase = artifacts.require("./MeetupBase.sol");


contract('MeetupBase', function([admin, organiser, assistant1, assistant2, 
                                 presenter1, attendee1]) {
  let meetupBaseInstance;

  beforeEach('setup contract for each test', async function () {
    meetupBaseInstance = await MeetupBase.new(organiser);    
    meetupBaseInstance.setOrganiser(organiser).send({        
      from: admin,
      gas: '100000000'
    });
  });

  describe('Initial meetup setup', () => {
    it('has initial organiser', async () => {
      assert.equal(await meetupBaseInstance.organiserAddress(), admin);
    });

    it('has initial assistant1', async () => {
      assert.equal(await meetupBaseInstance.assistantAddress_1(), admin);
    });

    it('has initial assistant2', async () => {
      assert.equal(await meetupBaseInstance.assistantAddress_2(), admin);
    });

  });

  // describe('Transfer meetup roles', () => {
  //   it('allows admin to transfer organiser role', async () => {
  //     await meetupBaseInstance.methods.setOrganiser(organiser).send({        
  //       from: admin,
  //       gas: '100000000'
  //     });

  //     assert.equal(await meetupBaseInstance.organiserAddress(), organiser);
  //   });


  // });

  



  // it("...can register organiser.", function() {
  //   assert.equal(await meetupBaseInstance.organiserAddress(), organiser)

  //   return MeetupBase.deployed().then(function(instance) {
  //     meetupBaseInstance = instance;

  //     return meetupBaseInstance.registerUser("Alice", {from: accounts[0]});
  //   }).then(function() {
  //     return meetupBaseInstance.users.call("Alice")
  //   }).then(function(reg_addr) {
  //     assert.equal(reg_addr, accounts[0], "The user 'Alice' was not registered.");
  //   });
  // });

  // it("...can register Bob.", function() {
  //   return MeetupBase.deployed().then(function(instance) {
  //     meetupBaseInstance = instance;

  //     return meetupBaseInstance.registerUser("Bob", {from: accounts[1]});
  //   }).then(function() {
  //     return meetupBaseInstance.users.call("Bob")
  //   }).then(function(reg_addr) {
  //     assert.equal(reg_addr, accounts[1], "The user 'Bob' was not registered.");
  //   });
  // });


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
