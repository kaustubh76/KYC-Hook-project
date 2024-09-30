// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "./CLIdentityHook.sol";
import "./BinIdentityHook.sol";
import "./ReputationSystem.sol";

contract AdminDashboard is AccessControl {
    CLIdentityHook public clHook;
    BinIdentityHook public binHook;
    ReputationSystem public reputationSystem;

    constructor(
        CLIdentityHook _clHook,
        BinIdentityHook _binHook,
        ReputationSystem _reputationSystem
    ) {
        clHook = _clHook;
        binHook = _binHook;
        reputationSystem = _reputationSystem;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    

    function setSwapLimits(BaseIdentityHook.VerificationLevel level, uint256 newLimit) external onlyRole(ADMIN_ROLE) {
        clHook.setSwapLimit(level, newLimit);
        binHook.setSwapLimit(level, newLimit);
    }

    function revokeVerification(address user) external onlyRole(ADMIN_ROLE) {
        clHook.revokeVerification(user);
        binHook.revokeVerification(user);
    }

    function pauseSystem() external onlyRole(ADMIN_ROLE) {
        clHook.pause();
        binHook.pause();
        reputationSystem.pause();
    }

    function unpauseSystem() external onlyRole(ADMIN_ROLE) {
        clHook.unpause();
        binHook.unpause();
        reputationSystem.unpause();
    }

    function getSystemStats() external view returns (
        uint256 clVerifiedUsers,
        uint256 binVerifiedUsers,
        uint256 totalReputationScore
    ) {
        clVerifiedUsers = clHook.getVerifiedUserCount();
        binVerifiedUsers = binHook.getVerifiedUserCount();
        totalReputationScore = reputationSystem.getTotalReputationScore();
    }

     function updateBrevisZKCoprocessor(IBrevisZKCoprocessor _newBrevisZKCoprocessor) external onlyRole(ADMIN_ROLE) {
        address oldCoprocessor = address(brevisZKCoprocessor);
        brevisZKCoprocessor = _newBrevisZKCoprocessor;
        clHook.updateBrevisZKCoprocessor(_newBrevisZKCoprocessor);
        binHook.updateBrevisZKCoprocessor(_newBrevisZKCoprocessor);
        emit BrevisZKCoprocessorUpdated(oldCoprocessor, address(_newBrevisZKCoprocessor));
    }
}