var MeetupBase = artifacts.require("./MeetupBase.sol"); 

contract('MeetupBase_rick', function([admin, assistant1, assistant2, 
  presenter1, attendee1, anyone]) {
  let meetupBaseInstance;

  beforeEach('setup contract for each test', async function () {
    meetupBaseInstance = await MeetupBase.new();
  });

  describe('Initial meetup setup', () => {
    it('admin is the owner', async () => {
      assert.equal(await meetupBaseInstance.organiserAddress(), admin);
    });

    it('assistant1 is not organiser', async () => {
      assert(await meetupBaseInstance.organiserAddress() !== assistant1, 'assistant1 is the organiser!');
    });

    it('admin is the assistant1', async () => {
      assert.equal(await meetupBaseInstance.assistantAddress_1(), admin);
    });

    it('admin is the assistant2', async () => {
      assert.equal(await meetupBaseInstance.assistantAddress_2(), admin);
    });

  });

  describe('async can register user', () => {
    it('register users', async () => {
      await meetupBaseInstance.registerUser("Zeming Yu", {from: admin});
      var addr =   await meetupBaseInstance.users.call("Zeming Yu");
      assert.equal(addr, admin, "The user 'Zeming Yu' was not registered.");
    });

    it('register users', async () => {
      await meetupBaseInstance.registerUser("Zeming Yu2", {from: assistant1});
      var addr = await meetupBaseInstance.users.call("Zeming Yu2");
      assert.equal(addr, assistant1, "The user 'Zeming Yu' was not registered.");
    });
  });

  describe('sync can register user', () => {
    it('register users',  () => {
      meetupBaseInstance.registerUser("Zeming Yu", {from: admin}).then( () => {
        meetupBaseInstance.users.call("Zeming Yu").then((addr) => {
          assert.equal(addr, admin, "The user 'Zeming Yu' was not registered.");
        });
      });
    });

    it('can re-register users by assistant1',  () => {
      meetupBaseInstance.registerUser("Zeming Yu", {from: assistant1}).then( () => {
        meetupBaseInstance.users.call("Zeming Yu").then((addr) => {
          assert(addr == assistant1, "The user 'Zeming Yu' was not reg by assistant1.");
        });
      });
    });

    it('can re-register users by anyone',  () => {
      meetupBaseInstance.registerUser("Zeming Yu", {from: anyone}).then( () => {
        meetupBaseInstance.users.call("Zeming Yu").then((addr) => {
          assert(addr == anyone, "The user 'Zeming Yu' was not reg by anyone.");
        });
      });
    });

  });


  describe('async can de-register user', () => {

    it('...register and de-register', async () => {
      await meetupBaseInstance.registerUser("Zeming Yu", {from: anyone});
      var addr =   await meetupBaseInstance.users.call("Zeming Yu");
      assert.equal(addr, anyone, "The user 'Zeming Yu' can not be registered.");

      await meetupBaseInstance.deregisterUser("Zeming Yu", {from: admin});
      var addr = await meetupBaseInstance.users.call("Zeming Yu");
      assert.equal(addr, 0x0, "The user 'Zeming Yu' can not be de-registered.");
    });

  });

  describe('create meetup', () => {
    it('...sync create ',  () => {
      meetupBaseInstance.getMeetupCount().then((before_cnt) => {
        meetupBaseInstance.createMeetup(60*60*24*7, 8, [anyone], {from: admin}).then(function(e,r){
          meetupBaseInstance.getMeetupCount().then((after_cnt) => {
            assert.equal(before_cnt.toNumber(), after_cnt.toNumber() -1, "create failed.");
          });
        });
      });
    })

    it('...async create ', async () => {
      before_cnt = await meetupBaseInstance.getMeetupCount();
      rs = await meetupBaseInstance.createMeetup(60*60*24*7, 8, [anyone], {from: admin});
      after_cnt = await meetupBaseInstance.getMeetupCount();
      //console.log(before_cnt);
      //console.log(rs);
      //console.log(after_cnt);
      assert.equal(before_cnt.toNumber(), after_cnt.toNumber() - 1, "create failed.");


    });

  });

});