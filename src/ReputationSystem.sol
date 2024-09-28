// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "./../lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";
import "./../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";

contract ReputationSystem is AccessControl, Pausable {
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    struct UserReputation {
        uint256 score;
        uint256 lastUpdateBlock;
    }

    mapping(address => UserReputation) public userReputations;

    uint256 public constant MAX_REPUTATION_SCORE = 1000;
    uint256 public constant MIN_REPUTATION_SCORE = 0;

    event ReputationUpdated(address indexed user, uint256 newScore);

    error InvalidReputationScore(uint256 score);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPDATER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function updateReputation(address user, uint256 score) external onlyRole(UPDATER_ROLE) whenNotPaused {
        if (score > MAX_REPUTATION_SCORE || score < MIN_REPUTATION_SCORE) {
            revert InvalidReputationScore(score);
        }

        userReputations[user] = UserReputation(score, block.number);
        emit ReputationUpdated(user, score);
    }

    function getReputation(address user) external view returns (uint256) {
        return userReputations[user].score;
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}