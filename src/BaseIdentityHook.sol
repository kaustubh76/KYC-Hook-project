// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "./../lib/openzeppelin-contracts-upgradeable/contracts/utils/PausableUpgradeable.sol";
import "./../lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "./BrevisZKCoprocessor.sol";
import "./ChallengeResponseVerifier.sol";
import "./ReputationSystem.sol";

abstract contract BaseIdentityHook is Initializable, AccessControlUpgradeable, PausableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    IBrevisZKCoprocessor public brevisZKCoprocessor;

    mapping(address => IdentityUtils.IdentityData) public identities;
    CountersUpgradeable.Counter private _verifiedUsersCount;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    uint256 public constant VERIFICATION_COOLDOWN = 1 days;

    event IdentityVerified(address indexed user, IdentityUtils.VerificationLevel level);
    event IdentityRevoked(address indexed user);
    event BrevisZKCoprocessorUpdated(address indexed oldCoprocessor, address indexed newCoprocessor);

    error InvalidZKProof();
    error VerificationCooldownNotMet(uint256 remainingTime);
    error UserNotVerified();

    function __BaseIdentityHook_init(IBrevisZKCoprocessor _brevisZKCoprocessor) internal initializer {
        __AccessControl_init();
        __Pausable_init();
        
        brevisZKCoprocessor = _brevisZKCoprocessor;
        
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(VERIFIER_ROLE, msg.sender);
    }

    function verifyIdentity(address user, bytes calldata zkProof) external whenNotPaused onlyRole(VERIFIER_ROLE) {
        IdentityUtils.IdentityData storage userData = identities[user];
        
        if (block.timestamp < userData.lastVerificationTime + VERIFICATION_COOLDOWN) {
            revert VerificationCooldownNotMet(userData.lastVerificationTime + VERIFICATION_COOLDOWN - block.timestamp);
        }

        if (!brevisZKCoprocessor.verifyProof(zkProof)) {
            revert InvalidZKProof();
        }
        
        IdentityUtils.VerificationLevel newLevel = IdentityUtils.getIdentityLevel(100); // Assuming highest level for valid proof
        
        if (!userData.isVerified) {
            _verifiedUsersCount.increment();
        }
        
        userData.level = newLevel;
        userData.lastVerificationTime = block.timestamp;
        userData.isVerified = true;
        
        emit IdentityVerified(user, newLevel);
    }

    function revokeIdentity(address user) external onlyRole(ADMIN_ROLE) {
        if (!identities[user].isVerified) {
            revert UserNotVerified();
        }
        delete identities[user];
        _verifiedUsersCount.decrement();
        emit IdentityRevoked(user);
    }

    function isVerified(address user) public view returns (bool) {
        return identities[user].isVerified;
    }

    function getIdentityLevel(address user) public view returns (IdentityUtils.VerificationLevel) {
        return identities[user].level;
    }

    function getVerifiedUserCount() public view returns (uint256) {
        return _verifiedUsersCount.current();
    }

    function updateBrevisZKCoprocessor(IBrevisZKCoprocessor _newBrevisZKCoprocessor) external onlyRole(ADMIN_ROLE) {
        address oldCoprocessor = address(brevisZKCoprocessor);
        brevisZKCoprocessor = _newBrevisZKCoprocessor;
        emit BrevisZKCoprocessorUpdated(oldCoprocessor, address(_newBrevisZKCoprocessor));
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}