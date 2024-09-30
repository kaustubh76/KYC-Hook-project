// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseIdentityHook.sol";
import "./interfaces/IBinIdentityHook.sol";
import "./ChallengeResponseVerifier.sol";
import "./ReputationSystem.sol";
import "./../lib/pancake-v4-core/src/pool-bin/interfaces/IBinPoolManager.sol";
import "./../lib/pancake-v4-core/src/types/PoolKey.sol";
import "./../lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";

contract BinIdentityHook is AccessControlUpgradeable, BaseIdentityHook, IBinIdentityHook {
    IBinPoolManager public binPoolManager;
    ChallengeResponseVerifier public challengeResponseVerifier;
    ReputationSystem public reputationSystem;
    uint256 public constant REPUTATION_THRESHOLD = 100;
    uint256 public constant MAX_VERIFICATIONS_PER_BLOCK = 10;

    mapping(uint256 => uint256) public verificationCountPerBlock;

    event HighReputationSwap(address indexed user, uint256 amount);

    function initialize(
        IBinPoolManager _binPoolManager,
        BrevisZKAdapter _brevisAdapter,
        ChallengeResponseVerifier _challengeResponseVerifier,
        ReputationSystem _reputationSystem
    ) public initializer {
        __AccessControl_init();
        __BaseIdentityHook_init(_brevisAdapter);

        binPoolManager = _binPoolManager;
        challengeResponseVerifier = _challengeResponseVerifier;
        reputationSystem = _reputationSystem;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function getHookPermissions() public pure override returns (uint16) {
        return BEFORE_SWAP_FLAG;
    }

    function beforeSwap(
        address sender,
        BinPoolKey calldata,
        IBinPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external override returns (bytes4) {
        uint256 swapAmount = params.amount;
        
        if (reputationSystem.getReputation(sender) >= REPUTATION_THRESHOLD) {
            emit HighReputationSwap(sender, swapAmount);
            return IBinIdentityHook.beforeSwap.selector;
        }

        _checkSwapLimit(sender, swapAmount);
        
        // Verify challenge response
        (bytes32 challenge, bytes memory signature) = abi.decode(hookData, (bytes32, bytes));
        challengeResponseVerifier.verifyChallengeResponse(challenge, signature);

        return IBinIdentityHook.beforeSwap.selector;
    }

    function verifyIdentity(address user, bytes[] calldata zkProofs) public override returns (bool) {
        require(verificationCountPerBlock[block.number] < MAX_VERIFICATIONS_PER_BLOCK, "Verification limit reached");
        verificationCountPerBlock[block.number]++;

        bool result = super.verifyIdentity(user, zkProofs);
        if (result) {
            uint256 newReputationScore = reputationSystem.getReputation(user) + 10;
            reputationSystem.updateReputation(user, newReputationScore);
        }
        return result;
    }
}