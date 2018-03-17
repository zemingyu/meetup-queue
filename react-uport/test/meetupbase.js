
var MeetupBase = artifacts.require("./MeetupBase.sol");

contract('MeetupBase', function(accounts) {

  it("...can register Alice.", function() {
    return MeetupBase.deployed().then(function(instance) {
      meetupBaseInstance = instance;

      return meetupBaseInstance.registerUser("Alice", {from: accounts[0]});
    }).then(function() {
      return meetupBaseInstance.users.call("Alice")
    }).then(function(reg_addr) {
      assert.equal(reg_addr, accounts[0], "The user 'Alice' was not registered.");
    });
  });

  it("...can register Bob.", function() {
    return MeetupBase.deployed().then(function(instance) {
      meetupBaseInstance = instance;

      return meetupBaseInstance.registerUser("Bob", {from: accounts[1]});
    }).then(function() {
      return meetupBaseInstance.users.call("Bob")
    }).then(function(reg_addr) {
      assert.equal(reg_addr, accounts[1], "The user 'Bob' was not registered.");
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
