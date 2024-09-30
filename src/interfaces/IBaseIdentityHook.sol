// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBaseIdentityHook {
    enum VerificationLevel { Unverified, Basic, Advanced, Premium }

    struct UserInfo {
        VerificationLevel level;
        uint256 lastVerificationTime;
        uint256 totalSwapVolume;
    }

    event IdentityVerified(address indexed user, VerificationLevel level);
    event SwapLimitUpdated(VerificationLevel indexed level, uint256 newLimit);
    event VerificationRevoked(address indexed user);
    event UserLevelUpgraded(address indexed user, VerificationLevel oldLevel, VerificationLevel newLevel);

    error SwapExceedsLimit(uint256 amount, uint256 limit);
    error VerificationCooldown(uint256 remainingTime);
    error InvalidVerificationLevel();
    error UnauthorizedAccess();
    error InsufficientProofs(uint256 provided, uint256 required);
    error MaxVerificationAttemptsReached();

    function verifyIdentity(address user, bytes[] calldata zkProofs) external returns (bool);
    function isVerified(address user) external view returns (bool);
    function getVerifiedUserCount() external view returns (uint256);
    function getUserInfo(address user) external view returns (UserInfo memory);
    function setSwapLimit(VerificationLevel level, uint256 newLimit) external;
    function revokeVerification(address user) external;
    function pause() external;
    function unpause() external;
    function getSwapLimit(VerificationLevel level) external view returns (uint256);
    function getRequiredProofs(VerificationLevel level) external view returns (uint256);

}