// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IBaseIdentityHook.sol";

interface IAdminDashboard {
    function setSwapLimits(IBaseIdentityHook.VerificationLevel level, uint256 newLimit) external;
    function revokeVerification(address user) external;
    function pauseSystem() external;
    function unpauseSystem() external;
    function getSystemStats() external view returns (
        uint256 clVerifiedUsers,
        uint256 binVerifiedUsers,
        uint256 totalReputationScore
    );
    function getCLHook() external view returns (address);
    function getBinHook() external view returns (address);
    function getReputationSystem() external view returns (address);
}