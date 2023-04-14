// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract thunderChatContract {
  event NewMessage(address indexed from, uint timestamp, string message);
  struct Message {
    address sender;
    string content;
    uint timestamp;
  }
  Message[] messages;
  function sendMessage(string calldata _content) public {
    messages.push(Message(msg.sender, _content, block.timestamp));
    emit NewMessage(msg.sender, block.timestamp, _content);
  }
  function getMessages() view public returns (Message[] memory) {
    return messages;
  }
}