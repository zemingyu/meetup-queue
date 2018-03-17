var MeetupBase = artifacts.require("./MeetupBase.sol");

contract('MeetupBase', function(accounts) {

  it("...can register user.", function() {
    return MeetupBase.deployed().then(function(instance) {
      meetupBaseInstance = instance;

      return meetupBaseInstance.registerUser("Alice", {from: accounts[0]});
    }).then(function() {
      return meetupBaseInstance.get.call();
    }).then(function(users["Alice"]) {
      assert.equal(users["Alice"], accounts[0], "The user 'Alice' was not registered.");
    });
  });

});
