// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../lib/pancake-v4-core/src/pool-bin/interfaces/IBinHooks.sol";
import "../../lib/pancake-v4-core/src/pool-bin/libraries/BinHooks.sol";
import "../../lib/pancake-v4-core/src/pool-bin/interfaces/IBinPoolManager.sol";

interface IBinIdentityHook is IBinHooks{
    function beforeSwap(
        address sender,
        IBinPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4);

    function afterSwap(
        address sender,
        IBinPoolManager.SwapParams calldata params,
        uint256 amountIn,
        uint256 amountOut,
        bytes calldata hookData
    ) external returns (bytes4);

    function getBinPoolManager() external view returns (IBinPoolManager);
}