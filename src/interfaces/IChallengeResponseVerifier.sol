// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IChallengeResponseVerifier {
    event ChallengeIssued(address indexed user, bytes32 challenge);
    event ChallengeVerified(address indexed user);

    error InvalidChallenge();
    error ChallengeNotIssued();
    error ChallengeCooldownNotMet(uint256 remainingTime);

    function issueChallenge(address user) external;
    function verifyChallengeResponse(bytes32 challenge, bytes memory signature) external;
    function pause() external;
    function unpause() external;
    function getChallengeForUser(address user) external view returns (bytes32);
    function getLastChallengeTime(address user) external view returns (uint256);
}