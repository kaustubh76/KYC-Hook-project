// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseIdentityHook.sol";
import "./interfaces/ICLIdentityHook.sol";
import "./../lib/pancake-v4-core/src/interfaces/IPoolManager.sol";
import "./../lib/pancake-v4-core/src/interfaces/IHooks.sol";
import "./../lib/pancake-v4-core/src/types/PoolKey.sol";

contract CLIdentityHook is BaseIdentityHook, ICLIdentityHook {
    IPoolManager public immutable poolManager;

    constructor(IPoolManager _poolManager, BrevisZKAdapter _brevisAdapter) 
        BaseIdentityHook(_brevisAdapter) 
    {
        poolManager = _poolManager;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: false,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    function beforeSwap(
        address sender,
        PoolKey calldata,
        IPoolManager.SwapParams calldata params,
        bytes calldata
    ) external override returns (bytes4) {
        uint256 swapAmount = params.amountSpecified < 0 
            ? uint256(-params.amountSpecified) 
            : uint256(params.amountSpecified);
        
        _checkSwapLimit(sender, swapAmount);
        
        return ICLIdentityHook.beforeSwap.selector;
    }

    function afterInitialize(address, PoolKey calldata, uint160, int24, bytes calldata)
        external
        override
        returns (bytes4)
    {
        return this.afterInitialize.selector;
    }

    function afterModifyPosition(address, PoolKey calldata, IPoolManager.ModifyPositionParams calldata, BalanceDelta, bytes calldata)
        external
        override
        returns (bytes4)
    {
        return this.afterModifyPosition.selector;
    }

    function afterSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata, BalanceDelta, bytes calldata)
        external
        override
        returns (bytes4)
    {
        return this.afterSwap.selector;
    }

    function afterDonate(address, PoolKey calldata, uint256, uint256, bytes calldata)
        external
        override
        returns (bytes4)
    {
        return this.afterDonate.selector;
    }
}