// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ThunderChatContract {
  
  address private owner;

  struct Message {
    address sender;
    string content;
    uint timestamp;
  }

  struct Friend {
    string name;
    address friendAddress;
    uint timestamp;
  }

  Message[] messages;
  Friend[] friendList;

  mapping (address => bool) private isFriendlistAddress;
  
  function isSenderAllowed(address sender) public view returns (bool) {
    return isFriendlistAddress[sender];
  }

  event NewMessage(address indexed from, uint timestamp, string message);
  event NewFriend(string name, address addr, uint timestamp);
  event RemoveFriend(address addr, uint timestamp);

  modifier onlyOwner() {
      require(msg.sender == owner, "Only the contract owner can call this function.");
      _;
  }

  constructor() {
      owner = msg.sender;
  }

  function sendMessage(string calldata _content) public {
    require(isFriendlistAddress[msg.sender], "Sender not allowed.");
    messages.push(Message(msg.sender, _content, block.timestamp));
    emit NewMessage(msg.sender, block.timestamp, _content);
  }

  function addToFriendlist(string calldata name, address addr) public onlyOwner {
    require(!isFriendlistAddress[addr], "Address is already allowed.");
    isFriendlistAddress[addr] = true;
    friendList.push(Friend(name, addr, block.timestamp));
    emit NewFriend(name, addr, block.timestamp);
  }

  function removeFromFriendlist(address addr) public onlyOwner {
    require(isFriendlistAddress[addr], "Address is not allowed.");
    isFriendlistAddress[addr] = false;
    for (uint i = 0; i < friendList.length; i++) {
        if (friendList[i].friendAddress == addr) {
            delete friendList[i];
            emit RemoveFriend(addr, block.timestamp);
            break;
        }
    }
  }

  function getAllFriends() view public returns (Friend[] memory) {
    return friendList;
  }

  function getMessages(address sender) public view returns (Message[] memory) {
    uint senderMessageCount = 0;

    // Count the number of messages sent by the sender
    for (uint i = 0; i < messages.length; i++) {
        if (messages[i].sender == sender) {
            senderMessageCount++;
        }
    }

    // Create a new array to store the sender's messages
    Message[] memory senderMessages = new Message[](senderMessageCount);

    // Copy the sender's messages to the new array
    uint j = 0;
    for (uint i = 0; i < messages.length; i++) {
        if (messages[i].sender == sender) {
            senderMessages[j] = Message(messages[i].sender, messages[i].content, messages[i].timestamp);
            j++;
        }
    }

    return senderMessages;
  }
}