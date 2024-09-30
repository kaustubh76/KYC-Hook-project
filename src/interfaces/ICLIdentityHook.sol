// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../../lib/pancake-v4-core/src/interfaces/IHooks.sol";
import "./../../lib/pancake-v4-core/src/interfaces/IPoolManager.sol";
import "./../../lib/pancake-v4-core/src/types/PoolKey.sol";
import "./IBaseIdentityHook.sol";

interface ICLIdentityHook is IHooks, IBaseIdentityHook {
    function initialize(IPoolManager _poolManager, IBrevisZKCoprocessor _brevisZKCoprocessor) external;
    
    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4);

     function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external returns (bytes4);

    function getPoolManager() external view returns (IPoolManager);
}