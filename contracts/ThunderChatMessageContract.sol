// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./ThunderChatProfileContract.sol"; // Import the path to the ThunderChatProfileContract

contract ThunderChatMessageContract is Initializable, ERC2771Context {  

    address private owner;
    

    struct Message {
        address sender;
        address receiver;
        string senderMessage;
        string receiverMessage;
        uint timestamp;
    }

    ThunderChatProfileContract thunderChatProfileContract; // Instance of the ThunderChatProfileContract

    Message[] messageList;

    event SendMessage(address sender, address receiver, string senderMessage, string receiverMessage, uint timestamp);

    function initialize() public initializer {
        owner = msg.sender;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(MinimalForwarder forwarder) ERC2771Context(address(forwarder)) {
    }

    // Set the address of the ThunderChatProfileContract
    function setProfileContract(address _profileContract) external {
        thunderChatProfileContract = ThunderChatProfileContract(_profileContract);
    }

    // Function to return the address of the ThunderChatProfileContract instance
    function getThunderChatProfileContractAddress() public view returns (address) {
        return address(thunderChatProfileContract);
    }

    // Send a message to a receiver
    function sendMessage(address receiver, string memory senderMessage, string memory receiverMessage) public {
        require(thunderChatProfileContract.getIsFriendlistAddress(_msgSender(), receiver), "Address is not in allowlist.");

        messageList.push(Message(_msgSender(), receiver, senderMessage, receiverMessage, block.timestamp));
        emit SendMessage(_msgSender(), receiver, senderMessage, receiverMessage, block.timestamp);
    }

    // Get all messages involving a specific address (as a sender or receiver)
    function getMessage(address addr) public view returns (Message[] memory) {
        uint y = 0;
        uint messagesCount = 0;
        for (uint i = 0; i < messageList.length; i++) {
            if (messageList[i].sender == addr || messageList[i].receiver == addr) {
                messagesCount++;
            }
        }

        Message[] memory allMessages = new Message[](messagesCount);

        for (uint x = 0; x < messageList.length; x++) {
            if (messageList[x].sender == addr || messageList[x].receiver == addr) {
                allMessages[y] = messageList[x];
                y++;
            }
        }

        return allMessages;
    }

    // Get messages involving a specific address (as a sender or receiver) after the specified "from" datetime
    function getMessagesFunctionFrom(address addr, uint fromTimestamp) public view returns (Message[] memory) {
        uint y = 0;
        uint messagesCount = 0;
        for (uint i = 0; i < messageList.length; i++) {
            if ((messageList[i].sender == addr || messageList[i].receiver == addr) && messageList[i].timestamp > fromTimestamp) {
                messagesCount++;
            }
        }

        Message[] memory allMessages = new Message[](messagesCount);

        for (uint x = 0; x < messageList.length; x++) {
            if ((messageList[x].sender == addr || messageList[x].receiver == addr) && messageList[x].timestamp > fromTimestamp) {
                allMessages[y] = messageList[x];
                y++;
            }
        }

        return allMessages;
    }

   
}
