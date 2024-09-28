// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title IdentityUtils
 * @dev Library for handling identity-related operations
 */
library IdentityUtils {
    using Strings for uint256;
    using ECDSA for bytes32;

    struct IdentityData {
        bytes32 dataHash;
        uint256 timestamp;
        uint8 verificationLevel;
        bool isVerified;
    }

    event IdentityVerified(address indexed user, uint8 verificationLevel);
    event IdentityRevoked(address indexed user);

    error InvalidIdentityData();
    error IdentityExpired();
    error UnauthorizedAccess();

    /**
     * @dev Hashes identity data
     * @param name The name of the identity holder
     * @param document The document number or identifier
     * @param dateOfBirth The date of birth as a unix timestamp
     * @return The keccak256 hash of the identity data
     */
    function hashIdentityData(
        string memory name,
        string memory document,
        uint256 dateOfBirth
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(name, document, dateOfBirth.toString()));
    }

    /**
     * @dev Verifies identity data against stored data
     * @param storedData The stored identity data
     * @param name The name to verify
     * @param document The document to verify
     * @param dateOfBirth The date of birth to verify
     * @return bool True if the data matches and is verified
     */
    function verifyIdentityData(
        IdentityData memory storedData,
        string memory name,
        string memory document,
        uint256 dateOfBirth
    ) internal pure returns (bool) {
        if (!storedData.isVerified) {
            return false;
        }
        bytes32 computedHash = hashIdentityData(name, document, dateOfBirth);
        return storedData.dataHash == computedHash;
    }

    /**
     * @dev Checks if an identity has expired
     * @param data The identity data to check
     * @param expirationPeriod The period after which an identity expires
     * @return bool True if the identity has expired
     */
    function isIdentityExpired(IdentityData memory data, uint256 expirationPeriod) internal view returns (bool) {
        return block.timestamp > data.timestamp + expirationPeriod;
    }

    /**
     * @dev Determines the identity verification level based on a score
     * @param verificationScore The verification score
     * @return uint8 The verification level (0-3)
     */
    function getIdentityLevel(uint256 verificationScore) internal pure returns (uint8) {
        if (verificationScore >= 90) return 3; // Advanced
        if (verificationScore >= 50) return 2; // Intermediate
        if (verificationScore >= 10) return 1; // Basic
        return 0; // Unverified
    }

    /**
     * @dev Verifies a signature against an identity hash
     * @param identityHash The hash of the identity data
     * @param signature The signature to verify
     * @return address The address that signed the message
     */
    function recoverSigner(bytes32 identityHash, bytes memory signature) internal pure returns (address) {
        return identityHash.toEthSignedMessageHash().recover(signature);
    }
}