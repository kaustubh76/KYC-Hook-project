// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "./../lib/openzeppelin-contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";
import "./../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
// import "./../lib/openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./BrevisZKAdapter.sol";
import "./ChallengeResponseVerifier.sol";
import "./ReputationSystem.sol";

abstract contract BaseIdentityHook is Initializable, AccessControlUpgradeable, PausableUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    BrevisZKAdapter public brevisAdapter;
    ChallengeResponseVerifier public challengeVerifier;
    ReputationSystem public reputationSystem;
    
    enum VerificationLevel { Unverified, Basic, Advanced, Premium }
    
    struct UserInfo {
        VerificationLevel level;
        uint256 lastVerificationTime;
        uint256 totalSwapVolume;
    }
    
    mapping(address => UserInfo) public userInfo;
    mapping(VerificationLevel => uint256) public swapLimits;
    mapping(VerificationLevel => uint256) public requiredProofs;
    EnumerableSetUpgradeable.AddressSet private verifiedUsers;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant VERIFICATION_COOLDOWN = 1 days;
    uint256 public constant MAX_VERIFICATION_ATTEMPTS = 3;
    uint256 public constant REPUTATION_THRESHOLD = 100;
    
    mapping(address => uint256) public verificationAttempts;
    mapping(address => uint256) public lastVerificationAttemptTime;

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

    function __BaseIdentityHook_init(
        BrevisZKAdapter _brevisAdapter,
        ChallengeResponseVerifier _challengeVerifier,
        ReputationSystem _reputationSystem
    ) internal initializer {
        __AccessControl_init();
        __Pausable_init();
        
        brevisAdapter = _brevisAdapter;
        challengeVerifier = _challengeVerifier;
        reputationSystem = _reputationSystem;
        
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        
        swapLimits[VerificationLevel.Unverified] = 1000 ether;
        swapLimits[VerificationLevel.Basic] = 10000 ether;
        swapLimits[VerificationLevel.Advanced] = 100000 ether;
        swapLimits[VerificationLevel.Premium] = type(uint256).max;

        requiredProofs[VerificationLevel.Basic] = 1;
        requiredProofs[VerificationLevel.Advanced] = 2;
        requiredProofs[VerificationLevel.Premium] = 3;
    }

    function verifyIdentity(address user, bytes[] calldata zkProofs) external whenNotPaused nonReentrant returns (bool) {
        if (block.timestamp < lastVerificationAttemptTime[user] + VERIFICATION_COOLDOWN) {
            revert VerificationCooldown(lastVerificationAttemptTime[user] + VERIFICATION_COOLDOWN - block.timestamp);
        }

        if (verificationAttempts[user] >= MAX_VERIFICATION_ATTEMPTS) {
            revert MaxVerificationAttemptsReached();
        }

        VerificationLevel newLevel = _determineVerificationLevel(zkProofs.length);
        if (newLevel <= userInfo[user].level) {
            revert InvalidVerificationLevel();
        }

        bool allValid = true;
        for (uint i = 0; i < zkProofs.length; i++) {
            if (!brevisAdapter.verifyProof(user, zkProofs[i])) {
                allValid = false;
                break;
            }
        }

        lastVerificationAttemptTime[user] = block.timestamp;
        verificationAttempts[user]++;

        if (allValid) {
            UserInfo storage info = userInfo[user];
            emit UserLevelUpgraded(user, info.level, newLevel);
            info.level = newLevel;
            info.lastVerificationTime = block.timestamp;
            verifiedUsers.add(user);
            verificationAttempts[user] = 0;
            emit IdentityVerified(user, newLevel);

            uint256 newReputationScore = reputationSystem.getReputation(user) + 10;
            reputationSystem.updateReputation(user, newReputationScore);
        }

        return allValid;
    }

    function _determineVerificationLevel(uint256 proofCount) internal view returns (VerificationLevel) {
        if (proofCount >= requiredProofs[VerificationLevel.Premium]) return VerificationLevel.Premium;
        if (proofCount >= requiredProofs[VerificationLevel.Advanced]) return VerificationLevel.Advanced;
        if (proofCount >= requiredProofs[VerificationLevel.Basic]) return VerificationLevel.Basic;
        return VerificationLevel.Unverified;
    }

    function setSwapLimit(VerificationLevel level, uint256 newLimit) external onlyRole(ADMIN_ROLE) {
        if (level == VerificationLevel.Unverified) revert InvalidVerificationLevel();
        swapLimits[level] = newLimit;
        emit SwapLimitUpdated(level, newLimit);
    }

    function revokeVerification(address user) external onlyRole(ADMIN_ROLE) {
        if (!verifiedUsers.contains(user)) revert UnauthorizedAccess();
        UserInfo storage info = userInfo[user];
        emit UserLevelUpgraded(user, info.level, VerificationLevel.Unverified);
        info.level = VerificationLevel.Unverified;
        info.lastVerificationTime = 0;
        verifiedUsers.remove(user);
        emit VerificationRevoked(user);
    }

    function isVerified(address user) external view returns (bool) {
        return verifiedUsers.contains(user);
    }

    function getVerifiedUserCount() external view returns (uint256) {
        return verifiedUsers.length();
    }

    function _checkSwapLimit(address user, uint256 amount) internal view {
        if (reputationSystem.getReputation(user) >= REPUTATION_THRESHOLD) {
            return; // High reputation users bypass swap limits
        }
        
        UserInfo storage info = userInfo[user];
        if (amount > swapLimits[info.level]) {
            revert SwapExceedsLimit(amount, swapLimits[info.level]);
        }
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}