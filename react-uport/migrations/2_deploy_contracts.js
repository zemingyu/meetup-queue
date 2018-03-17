// var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var MeetupBase = artifacts.require("./MeetupBase.sol");

module.exports = function(deployer) {
  deployer.deploy(MeetupBase);
};
