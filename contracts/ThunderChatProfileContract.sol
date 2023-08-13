// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ThunderChatProfileContract is Initializable, ERC2771Context {  

    address private owner;

    struct Profile {
        address walletAddress;
        string userId;
        string name;
        string description;
        string photoURL;
        string publicKey;
        string referrerCode; // New field for the referrer code
        string referredBy;   // New field for the referred by code
        string fcmToken;
        uint timestamp;
    }

    struct ProfileWithFriendList {
        address walletAddress;
        string userId;
        string name;
        string description;
        string photoURL;
        string publicKey;
        string referrerCode; // New field for the referrer code
        string referredBy;   // New field for the referred by code
        string fcmToken;
        uint timestamp;
        FriendProfile[] friends;
        
    }

    struct Friend {
        address walletAddress1;
        address walletAddress2;
        bool isApproved;
        uint timestamp;
    }

    struct FriendProfile {
        address walletAddress;
        string userId;
        string name;
        string description;
        string photoURL;
        string publicKey;
        string referrerCode; // New field for the referrer code
        string referredBy;   // New field for the referred by code
        string fcmToken;
        uint timestamp;
        bool isApproved;
        bool isRequester;
        uint timestampadded;
    }

    struct Message {
        address sender;
        address receiver;
        string senderMessage;
        string receiverMessage;
        uint timestamp;
    }

    Profile[] profiles;
    Friend[] friendList;
    Message[] messageList;

    function initialize() public initializer {
        owner = msg.sender;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(MinimalForwarder forwarder) // Initialize trusted forwarder
        ERC2771Context(address(forwarder)) {
    }

    mapping (address => bool) private isProfilelistAddress;
    mapping (address => mapping (address => bool)) private isFriendlistAddress;

    event AddProfile(address walletAddress, string userId, string name, string photoURL, string publicKey, uint timestamp);
    event AddFriend(address walletAddress1, address walletAddress2, uint timestamp);
    event UpdateProfile(address walletAddress, string name, string description, string photoURL, uint timestamp);
    event ApproveFriend(address walletAddress1, address walletAddress2, bool approve, uint timestamp);
    event DeleteFriend(address walletAddress1, address walletAddress2, uint timestamp);
    event SendMessage(address sender, address receiver, string senderMessage , string receiverMessage, uint timestamp);

    function generateReferrerCode() private view returns (string memory) {
        bytes memory chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
        uint256 charLength = chars.length;
        bytes memory code = new bytes(8);
        bool codeExists;

        do {
            // Generate the referrer code
            for (uint256 i = 0; i < 8; i++) {
                uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, i))) % charLength;
                code[i] = chars[randomIndex];
            }

            // Check if the generated code already exists in the profiles
            codeExists = false;
            for (uint256 j = 0; j < profiles.length; j++) {
                if (keccak256(bytes(profiles[j].referrerCode)) == keccak256(code)) {
                    codeExists = true;
                    break;
                }
            }
        } while (codeExists);

        return string(code);
    }


    function addProfile(string calldata _userId, string calldata _name, string calldata _photoURL, string calldata referredBy, string calldata _publicKey, string calldata fcmToken) public {
        require(!isProfilelistAddress[_msgSender()], "Profile already exists.");

    string memory referrerCode = generateReferrerCode();
    Profile memory profileData = Profile({
        walletAddress: _msgSender(),
        userId: _userId,
        name: _name,
        description: "I am using Thunder Chat",
        photoURL: _photoURL,
        publicKey: _publicKey,
        referrerCode: referrerCode,
        referredBy: referredBy,
        fcmToken: fcmToken,
        timestamp: block.timestamp
    });
    
    profiles.push(profileData);
    isProfilelistAddress[_msgSender()] = true;
        emit AddProfile(_msgSender(), _userId, _name, _photoURL, _publicKey, block.timestamp);
    }

    // Add a public getter function for the isFriendlistAddress mapping
    function getIsFriendlistAddress(address _user, address _friend) public view returns (bool) {
        return isFriendlistAddress[_user][_friend];
    }
    

    function getAllProfiles() view public returns (Profile[] memory) {
        return profiles;
    }

    function getProfile(address _walletAddress) public view returns (Profile memory)  {

        Profile memory info;
        
        // Count the number of messages sent by the sender
        for (uint i = 0; i < profiles.length; i++) {
            if (profiles[i].walletAddress == _walletAddress) {
                info = Profile(profiles[i].walletAddress, profiles[i].userId, profiles[i].name, profiles[i].description, profiles[i].photoURL, profiles[i].publicKey, profiles[i].referrerCode, profiles[i].referredBy, profiles[i].fcmToken, profiles[i].timestamp);
                break;
            }
        }
        return info;
    }

    function getProfileWithFriendList(address _walletAddress) public view returns (ProfileWithFriendList memory)  {
        uint friends = 0;
        uint y=0;
        
        ProfileWithFriendList memory info;
        
        for (uint x = 0; x < friendList.length; x++) {
            if (friendList[x].walletAddress1 == _walletAddress || friendList[x].walletAddress2 == _walletAddress) {
            friends++;          
            }
        }

        FriendProfile[] memory friendsProfileList = new FriendProfile[](friends);
        Profile memory tempProfile;
        for (uint x = 0; x < friendList.length; x++) {
            if (friendList[x].walletAddress1 == _walletAddress || friendList[x].walletAddress2 == _walletAddress) {
                
                if (friendList[x].walletAddress1 == _walletAddress){
                    tempProfile = getProfile(friendList[x].walletAddress2);
                    friendsProfileList[y].isRequester = true;
                }
                else{
                    tempProfile = getProfile(friendList[x].walletAddress1);
                    friendsProfileList[y].isRequester = false;
                }
                
                friendsProfileList[y].walletAddress = tempProfile.walletAddress;
                friendsProfileList[y].userId = tempProfile.userId;
                friendsProfileList[y].name = tempProfile.name;
                friendsProfileList[y].description = tempProfile.description;
                friendsProfileList[y].photoURL = tempProfile.photoURL;
                friendsProfileList[y].publicKey = tempProfile.publicKey;
                friendsProfileList[y].referrerCode = tempProfile.referrerCode;
                friendsProfileList[y].referredBy = tempProfile.referredBy;
                friendsProfileList[y].fcmToken = tempProfile.fcmToken;
                friendsProfileList[y].timestamp = tempProfile.timestamp;
                friendsProfileList[y].isApproved = friendList[x].isApproved;
                friendsProfileList[y].timestampadded = friendList[x].timestamp;
            y++;
            }
        }

        // Count the number of messages sent by the sender
        for (uint i = 0; i < profiles.length; i++) {
            if (profiles[i].walletAddress == _walletAddress) {
                info = ProfileWithFriendList(profiles[i].walletAddress, profiles[i].userId, profiles[i].name , profiles[i].description, profiles[i].photoURL, profiles[i].publicKey, profiles[i].referrerCode, profiles[i].referredBy, profiles[i].fcmToken,  profiles[i].timestamp, friendsProfileList);
                break;
            }
        }
        return info;
    }
  

  function updateProfile(string calldata _name, string calldata _description, string calldata _photoURL, string calldata _fcmToken) public {
    require(isProfilelistAddress[_msgSender()], "Profile does not exist.");
    
    for (uint i = 0; i < profiles.length; i++) {
        if (profiles[i].walletAddress == _msgSender()) {
           
            profiles[i].name = _name;
            profiles[i].description = _description;
            profiles[i].photoURL = _photoURL;
            profiles[i].fcmToken = _fcmToken;
            profiles[i].timestamp = block.timestamp;
            break;
        }
    }
    emit UpdateProfile(_msgSender(), _name, _description, _photoURL, block.timestamp);
  }  

  
  function UpdateProfileFcmToken(string calldata _fcmToken) public {
    require(isProfilelistAddress[_msgSender()], "Profile does not exist.");
    
    for (uint i = 0; i < profiles.length; i++) {
        if (profiles[i].walletAddress == _msgSender()) {
          
            profiles[i].fcmToken = _fcmToken;
            profiles[i].timestamp = block.timestamp;
            break;
        }
    }
    //emit UpdateProfileFcmToken(_msgSender(), _fcmToken, block.timestamp);
  }  


  function deleteProfile() public {

    delete isProfilelistAddress[_msgSender()];
    
    for (uint i = 0; i < profiles.length; i++) {
        if (profiles[i].walletAddress == _msgSender()) {
           
            delete profiles[i];
     
            break;
        }
    }    
  }  

    function addToFriendRequestlist(address addr) public {
        require(!isFriendlistAddress[_msgSender()][addr], "Address is already added or waiting for acceptance.");
        require(!isFriendlistAddress[addr][_msgSender()], "Address is already added or waiting for acceptance.");
        
        isFriendlistAddress[_msgSender()][addr] = true;
        isFriendlistAddress[addr][_msgSender()] = true;
        
        friendList.push(Friend(_msgSender(), addr, false ,block.timestamp));

        emit  AddFriend(_msgSender(), addr, block.timestamp);

    }


    function approveFriend(address addr) public {
        
        for (uint i = 0; i < friendList.length; i++) {
            if (friendList[i].walletAddress2 == _msgSender() && friendList[i].walletAddress1 == addr) {
                friendList[i].isApproved = true;
                friendList[i].timestamp = block.timestamp;
                break;
            }
        }

        emit  ApproveFriend(_msgSender(), addr, true, block.timestamp);
    }

    function deleteFriend(address addr) public {
        
        for (uint i = 0; i < friendList.length; i++) {
            if ((friendList[i].walletAddress2 == _msgSender() && friendList[i].walletAddress1 == addr) || (friendList[i].walletAddress1 == _msgSender() && friendList[i].walletAddress2 == addr)) {
                delete friendList[i];
                
                emit  DeleteFriend(addr, _msgSender(), block.timestamp);
                break;
            }
        }
        
        delete isFriendlistAddress[addr][_msgSender()];
        delete isFriendlistAddress[_msgSender()][addr];

        // Physically remove the friend connection from isFriendlistAddress mapping
        
    }

    function isAccountExist()  public view returns (bool exist)  {
        return isProfilelistAddress[_msgSender()];
        
    }

    function isUserIdExist(string calldata _userId) public view returns (bool exist)  {
        bool _exist=false;
        
        for (uint i = 0; i < profiles.length; i++) {
            if (keccak256(abi.encodePacked(profiles[i].userId)) == keccak256(abi.encodePacked(_userId))) {
                _exist=true;
                break;
            }
        }

        return _exist;
    }

    function isUserNameExist(string calldata _userName) public view returns (bool exist)  {
        bool _exist=false;
        
        for (uint i = 0; i < profiles.length; i++) {
            if (keccak256(abi.encodePacked(profiles[i].name)) == keccak256(abi.encodePacked(_userName))) {
                _exist=true;
                break;
            }
        }

        return _exist;
    }

    function searchProfiles(string calldata searchName,address senderAddress) public view returns (Profile[] memory) {
       

        Profile[] memory searchResults = new Profile[](1);
        uint index = 0;

        for (uint i = 0; i < profiles.length; i++) {
            address profileAddress = profiles[i].walletAddress;

            if (
                keccak256(bytes(profiles[i].name)) == keccak256(bytes(searchName)) &&
                profileAddress != senderAddress &&
                !isFriendlistAddress[senderAddress][profileAddress] &&
                !isFriendlistAddress[profileAddress][senderAddress]
            ) {
                searchResults[index] = profiles[i];
                index++;
            }
        }

        return searchResults;
    }

    function contains(string memory _str, string memory _substr) internal pure returns (bool) {
        bytes memory strBytes = bytes(_str);
        bytes memory substrBytes = bytes(_substr);

        if (strBytes.length < substrBytes.length) {
            return false;
        }

        for (uint i = 0; i <= strBytes.length - substrBytes.length; i++) {
            bool found = true;
            for (uint j = 0; j < substrBytes.length; j++) {
                if (strBytes[i + j] != substrBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }
        return false;
    }

    function getProfilesByReferrerCode(string calldata referrerCode) public view returns (Profile[] memory) {
    Profile[] memory matchingProfiles;
    uint256 matchingCount = 0;

    for (uint256 i = 0; i < profiles.length; i++) {
        if (keccak256(bytes(profiles[i].referredBy)) == keccak256(bytes(referrerCode))) {
            // Add the matching profile to the array
            matchingCount++;
            
        }
    }

    matchingProfiles = new Profile[](matchingCount);
    uint index = 0;

    for (uint256 j = 0; j < matchingCount - 1; j++) {
        if (keccak256(bytes(profiles[j].referredBy)) == keccak256(bytes(referrerCode))) {
            // Add the matching profile to the array
            matchingProfiles[index] = profiles[j];
            index++;
        }
        
    }

    
    return matchingProfiles;
}
    
}