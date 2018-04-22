// var SimpleStorage = artifacts.require("./SimpleStorage.sol");

var BTTSLib = artifacts.require("./BTTSLib.sol");
// var BTTSTokenFactory = artifacts.require("./BTTSTokenFactory.sol");
// var Members = artifacts.require("./Members.sol");
// var MeetupBase = artifacts.require("./MeetupBase.sol");

module.exports = function(deployer) {
  deployer.deploy(BTTSLib);  
};


// module.exports = function(deployer) {
//   deployer.deploy(BTTSLib).then(() => {
//     deployer.deploy(BTTSTokenFactory).then(()=> {
//       deployer.deploy(Members).then(() => {
//         deployer.deploy(MeetupBase);
//       });
//     });
//   });

//   deployer.link(BTTSLib, BTTSTokenFactory, Members, MeetupBase);
// };

// module.exports = function(deployer) {
//   deployer.deploy(BTTSTokenFactory);
// };

