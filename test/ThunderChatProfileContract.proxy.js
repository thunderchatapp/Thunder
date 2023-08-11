
const { expect } = require('chai');
 
let ThunderChatProfileContract;
let thunderChatProfileContract;
 
// Start test block
describe('ThunderChatProfileContract (proxy)', function () {
  beforeEach(async function () {
    ThunderChatProfileContract = await ethers.getContractFactory("ThunderChatProfileContract");
    thunderChatProfileContract = await upgrades.deployProxy(ThunderChatProfileContract, ["0x412F1D5417a8288F570b4d4d93ACdE38910A8ba0"], {initializer: 'constructor'});
  });
 
  // Test case
  it('retrieve returns a value previously initialized', async function () {
    await thunderChatProfileContract.addProfile("123@123.com","asd","asd","asd");
 
    // Test if the returned value is the same one
    // Note that we need to use strings to compare the 256 bit integers
    //expect((await box.retrieve()).toString()).to.equal('42');

    console.log("getAllProfiles:", (await thunderChatProfileContract.getAllProfiles()).toString())
  });
});