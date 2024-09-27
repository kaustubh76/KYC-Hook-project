// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPancakeV4PoolManager {
    function createPool(address token0, address token1, uint24 fee, uint256 binStep) external returns (bytes32 poolId);
    function enableHook(bytes32 poolId, address hook) external;
    function swap(bytes32 poolId, uint256 amountIn, address tokenIn, address recipient) external returns (uint256 amountOut);
    function flashLoan(address receiver, address asset, uint256 amount, bytes calldata params) external;
}