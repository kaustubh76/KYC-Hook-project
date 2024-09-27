// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIdentityVerifier {
    struct IdentityProof {
        bytes32 identityHash;
        bytes zkProof;
        uint256 expirationTime;
    }

    struct IdentityMetadata {
        bytes32 identityHash;
        uint256 verificationTime;
        uint256 expirationTime;
        uint8 verificationLevel;
    }

    event IdentityVerified(address indexed user, bytes32 indexed identityHash, uint256 expirationTime);
    event IdentityRevoked(address indexed user, bytes32 indexed identityHash);
    event VerificationLevelUpdated(address indexed user, uint8 newLevel);

    /// @notice Verifies the identity of a user
    /// @param user The address of the user
    /// @param proof The zero-knowledge proof of the user's identity
    /// @return success True if the identity is successfully verified
    function verifyIdentity(address user, IdentityProof calldata proof) external returns (bool success);

    /// @notice Revokes the identity of a user
    /// @param user The address of the user
    /// @return success True if the identity is successfully revoked
    function revokeIdentity(address user) external returns (bool success);

    /// @notice Checks if a user's identity is verified
    /// @param user The address of the user
    /// @return isVerified True if the user's identity is verified and not expired
    function isIdentityVerified(address user) external view returns (bool isVerified);

    /// @notice Gets the identity metadata of a verified user
    /// @param user The address of the user
    /// @return metadata The metadata of the user's identity
    function getIdentityMetadata(address user) external view returns (IdentityMetadata memory metadata);

    /// @notice Updates the verification level of a user
    /// @param user The address of the user
    /// @param newLevel The new verification level
    /// @return success True if the verification level is successfully updated
    function updateVerificationLevel(address user, uint8 newLevel) external returns (bool success);

    /// @notice Extends the expiration time of a user's identity verification
    /// @param user The address of the user
    /// @param extensionPeriod The period (in seconds) to extend the expiration time
    /// @return success True if the expiration time is successfully extended
    function extendVerification(address user, uint256 extensionPeriod) external returns (bool success);
}