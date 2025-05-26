// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReputationScoreTracker {
    struct User {
        uint256 reputationScore;
        mapping(uint256 => Action) actions; // Action ID to Action mapping
        uint256 actionCount; // Total actions taken by the user
    }

    struct Action {
        uint256 timestamp;
        string description;
        int256 scoreChange; // Positive or negative change in reputation
    }

    mapping(address => User) private users;
    address public owner;

    event ReputationUpdated(address indexed user, uint256 newScore);
    event ActionLogged(address indexed user, uint256 actionId, string description, int256 scoreChange);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function logAction(string memory description, int256 scoreChange) public {
        User storage user = users[msg.sender];
        user.actionCount++;
        user.actions[user.actionCount] = Action(block.timestamp, description, scoreChange);
        
        // Update reputation score
        user.reputationScore = uint256(int256(user.reputationScore) + scoreChange);
        
        emit ActionLogged(msg.sender, user.actionCount, description, scoreChange);
        emit ReputationUpdated(msg.sender, user.reputationScore);
    }

    function getReputationScore(address userAddress) public view returns (uint256) {
        return users[userAddress].reputationScore;
    }

    function getAction(address userAddress, uint256 actionId) public view returns (uint256, string memory, int256) {
        Action storage action = users[userAddress].actions[actionId];
        return (action.timestamp, action.description, action.scoreChange);
    }

    function getTotalActions(address userAddress) public view returns (uint256) {
        return users[userAddress].actionCount;
    }

    function resetReputation(address userAddress) public onlyOwner {
        users[userAddress].reputationScore = 0;
        emit ReputationUpdated(userAddress, 0);
    }
}
