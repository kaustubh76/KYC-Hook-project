// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract ChallengeResponseVerifier {
    using ECDSA for bytes32;

    mapping(address => bytes32) public challenges;

    event ChallengeIssued(address indexed user, bytes32 challenge);
    event ChallengeVerified(address indexed user);

    error InvalidChallenge();
    error ChallengeNotIssued();

    function issueChallenge(address user) external {
        bytes32 challenge = keccak256(abi.encodePacked(user, block.timestamp, blockhash(block.number - 1)));
        challenges[user] = challenge;
        emit ChallengeIssued(user, challenge);
    }

    function verifyChallengeResponse(bytes32 challenge, bytes memory signature) external {
        if (challenges[msg.sender] != challenge) {
            revert ChallengeNotIssued();
        }

        address signer = challenge.toEthSignedMessageHash().recover(signature);
        if (signer != msg.sender) {
            revert InvalidChallenge();
        }

        delete challenges[msg.sender];
        emit ChallengeVerified(msg.sender);
    }
}