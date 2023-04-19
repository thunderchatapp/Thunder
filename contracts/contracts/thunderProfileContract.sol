// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
contract ThunderProfileContract {
  
  address private owner;

  struct Profile {
    address walletAddress;
    address chatAddress;
    string name;
    string description;
    string pic;
    string publicKey;
    uint timestamp;
  }

  Profile[] profiles;

  mapping (address => bool) private isProfilelistAddress;

  event AddProfile(address walletAddress, address chatAddress, string name, string description, string pic, string publicKey, uint timestamp);
  
  modifier onlyOwner() {
      require(msg.sender == owner, "Only the contract owner can call this function.");
      _;
  }

  constructor() {
      owner = msg.sender;
  }

  function addProfile(address _chatAddress, string calldata _name, string calldata _description, string calldata _pic, string calldata _publicKey) public {
    
    require(!isProfilelistAddress[msg.sender], "Profile already exist.");

    profiles.push(Profile(msg.sender, _chatAddress, _name, _description, _pic, _publicKey, block.timestamp));

    emit AddProfile(msg.sender, _chatAddress, _name, _description, _pic, _publicKey, block.timestamp);

  }

  function getAllProfiles() view public returns (Profile[] memory) {
    return profiles;
  }

  function getProfile(address _walletAddress) public view returns (Profile[] memory)  {

    Profile[] memory info = new Profile[](1);

    // Count the number of messages sent by the sender
    for (uint i = 0; i < profiles.length; i++) {
        if (profiles[i].walletAddress == _walletAddress) {
            info[0] = Profile(profiles[i].walletAddress, profiles[i].chatAddress, profiles[i].name, profiles[i].description, profiles[i].pic, profiles[i].publicKey, profiles[i].timestamp);
        }
    }
    return info;
  }
  
}