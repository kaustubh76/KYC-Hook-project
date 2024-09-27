// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BinPoolManager.sol";
import "./ClPoolManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PoolFactory is Ownable {
    BinPoolManager public immutable binPoolManager;
    ClPoolManager public immutable clPoolManager;

    mapping(bytes32 => bool) public isBinPool;
    mapping(bytes32 => bool) public isClPool;

    event BinPoolCreated(bytes32 indexed poolId, address token0, address token1, uint24 fee, uint256 binStep);
    event ClPoolCreated(bytes32 indexed poolId, address token0, address token1, uint24 fee, int24 tickSpacing);

    constructor(address _binPoolManager, address _clPoolManager) {
        binPoolManager = BinPoolManager(_binPoolManager);
        clPoolManager = ClPoolManager(_clPoolManager);
    }

    function createBinPool(address token0, address token1, uint24 fee, uint256 binStep) external returns (bytes32 poolId) {
        poolId = binPoolManager.createPool(token0, token1, fee, binStep);
        isBinPool[poolId] = true;
        emit BinPoolCreated(poolId, token0, token1, fee, binStep);
    }

    function createClPool(address token0, address token1, uint24 fee, int24 tickSpacing) external returns (bytes32 poolId) {
        poolId = clPoolManager.createPool(token0, token1, fee, tickSpacing);
        isClPool[poolId] = true;
        emit ClPoolCreated(poolId, token0, token1, fee, tickSpacing);
    }

    function enableHook(bytes32 poolId, address hook) external onlyOwner {
        if (isBinPool[poolId]) {
            binPoolManager.enableHook(poolId, hook);
        } else if (isClPool[poolId]) {
            clPoolManager.enableHook(poolId, hook);
        } else {
            revert("PoolFactory: POOL_NOT_FOUND");
        }
    }

    function getPool(bytes32 poolId) external view returns (address poolManager, bool isBin) {
        if (isBinPool[poolId]) {
            return (address(binPoolManager), true);
        } else if (isClPool[poolId]) {
            return (address(clPoolManager), false);
        } else {
            revert("PoolFactory: POOL_NOT_FOUND");
        }
    }
}