// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IIdentityVerifier.sol";
import "./ZKProofGenerator.sol";

contract IdentityManager is IIdentityVerifier, AccessControl, Pausable {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    ZKProofGenerator public immutable zkProofGenerator;

    mapping(address => IdentityMetadata) private identities;

    constructor(address _zkProofGenerator) {
        zkProofGenerator = ZKProofGenerator(_zkProofGenerator);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(VERIFIER_ROLE, msg.sender);
    }

    function verifyIdentity(address user, IdentityProof calldata proof) 
        external 
        override 
        onlyRole(VERIFIER_ROLE) 
        whenNotPaused 
        returns (bool success) 
    {
        require(zkProofGenerator.verifyIdentityProof(user, proof.zkProof), "Invalid ZK proof");
        
        identities[user] = IdentityMetadata({
            identityHash: proof.identityHash,
            verificationTime: block.timestamp,
            expirationTime: proof.expirationTime,
            verificationLevel: 1
        });

        emit IdentityVerified(user, proof.identityHash, proof.expirationTime);
        return true;
    }

    function revokeIdentity(address user) 
        external 
        override 
        onlyRole(DEFAULT_ADMIN_ROLE) 
        whenNotPaused 
        returns (bool success) 
    {
        require(identities[user].identityHash != bytes32(0), "Identity not found");
        emit IdentityRevoked(user, identities[user].identityHash);
        delete identities[user];
        return true;
    }

    function isIdentityVerified(address user) public view override returns (bool isVerified) {
        return identities[user].identityHash != bytes32(0) && block.timestamp <= identities[user].expirationTime;
    }

    function getIdentityMetadata(address user) external view override returns (IdentityMetadata memory metadata) {
        return identities[user];
    }

    function updateVerificationLevel(address user, uint8 newLevel) 
        external 
        override 
        onlyRole(VERIFIER_ROLE) 
        whenNotPaused 
        returns (bool success) 
    {
        require(isIdentityVerified(user), "Identity not verified or expired");
        identities[user].verificationLevel = newLevel;
        emit VerificationLevelUpdated(user, newLevel);
        return true;
    }

    function extendVerification(address user, uint256 extensionPeriod) 
        external 
        override 
        onlyRole(VERIFIER_ROLE) 
        whenNotPaused 
        returns (bool success) 
    {
        require(isIdentityVerified(user), "Identity not verified or expired");
        identities[user].expirationTime += extensionPeriod;
        emit IdentityVerified(user, identities[user].identityHash, identities[user].expirationTime);
        return true;
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}