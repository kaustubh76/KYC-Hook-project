// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IReputationSystem {
    event ReputationUpdated(address indexed user, uint256 newScore);

    error InvalidReputationScore(uint256 score);

    function updateReputation(address user, uint256 score) external;
    function getReputation(address user) external view returns (uint256);
    function getTotalReputationScore() external view returns (uint256);
    function pause() external;
    function unpause() external;
}