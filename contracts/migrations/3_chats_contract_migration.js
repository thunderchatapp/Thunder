const NotesContract = artifacts.require("ChatsContract");

module.exports = function (deployer) {
  deployer.deploy(NotesContract);
};