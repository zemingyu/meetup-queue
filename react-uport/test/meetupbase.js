
var MeetupBase = artifacts.require("./MeetupBase.sol");


contract('MeetupBase', function([admin, organiser, assistant1, assistant2, 
                                 presenter1, attendee1]) {
  let meetupBaseInstance;

  beforeEach('setup contract for each test', async function () {
    meetupBaseInstance = await MeetupBase.new(admin);

    await meetupBaseInstance.setOrganiser(organiser, {from: admin});
    await meetupBaseInstance.setAssistant_1(assistant1, {from: admin});
    await meetupBaseInstance.setAssistant_2(assistant2, {from: admin});
  });

  // beforeEach("setup contract for each test", function() {
  //   return MeetupBase.deployed().then(function(instance) {
  //     meetupBaseInstance = instance;

  //     return meetupBaseInstance.setOrganiser(organiser, {from: admin});
  //   }).then(function() {
  //     return meetupBaseInstance.setAssistant_1(assistant1, {from: admin});
  //   }).then(function() {
  //     return meetupBaseInstance.setAssistant_2(assistant2, {from: admin});
  //   });
  // });


  // describe('Initial meetup setup', () => {
  //   it('has initial organiser', async () => {
  //     assert.equal(await meetupBaseInstance.organiserAddress(), organiser);
  //   });

  //   it('has initial assistant1', async () => {
  //     assert.equal(await meetupBaseInstance.assistantAddress_1(), assistant1);
  //   });

  //   it('has initial assistant2', async () => {
  //     assert.equal(await meetupBaseInstance.assistantAddress_2(), assistant2);
  //   });

  // });



  it("...can register user.", () => {
    return MeetupBase.deployed().then((instance) => {
      meetupBaseInstance = instance;

      return meetupBaseInstance.registerUser("Zeming Yu", {from: admin});
    }).then( () => {
      return meetupBaseInstance.users.call("Zeming Yu")
    }).then( (reg_addr) => {
      assert.equal(reg_addr, admin, "The user 'Zeming Yu' was not registered.");
    });
  });

    // it('can register Zeming Yu', () => {
    //   return meetupBaseInstance.registerUser("Zeming Yu", {from: admin});
    //   }).then( () => {
    //     assert.equal(meetupBaseInstance.users.call("Zeming Yu"), admin);
    //   });
    // });
    

    // it('can register BokkyPooBah', async () => {
    //   await meetupBaseInstance.registerUser("BokkyPooBah", {from: organiser});
    //   assert.equal(await meetupBaseInstance.users.call("BokkyPooBah"), organiser);
    // });

    // it('can register David Lim', async () => {
    //   await meetupBaseInstance.registerUser("David Lim", {from: assistant1});
    //   assert.equal(await meetupBaseInstance.users.call("David Lim"), assistant1);
    // });

    // it('can register James Zaki', async () => {
    //   await meetupBaseInstance.registerUser("James Zaki", {from: assistant2});
    //   assert.equal(await meetupBaseInstance.users.call("James Zaki"), assistant2);
    // });

    // it('can register Sanjev Sunder', async () => {
    //   await meetupBaseInstance.registerUser("Sanjev Sunder", {from: presenter1});
    //   assert.equal(await meetupBaseInstance.users.call("Sanjev Sunder"), presenter1);
    // });

    // it('can register Andrew', async () => {
    //   await meetupBaseInstance.registerUser("Andrew", {from: attendee1});
    //   assert.equal(await meetupBaseInstance.users.call("Andrew"), attendee1);
    // });

    // it('allows assistants to deregister Zeming Yu', async () => {
    //   await meetupBaseInstance.deregisterUser("Zeming Yu", {from: organiser});
    //   // console.log(await meetupBaseInstance.users.call("Zeming Yu"));      
    //   assert.equal(await meetupBaseInstance.users.call("Zeming Yu"), 0x0);
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
