// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CLIdentityHook.sol";

contract CLIdentityHookTest is Test {
    CLIdentityHook public hook;

    address public constant ADMIN = address(0x1);
    address public constant USER = address(0x2);

    function setUp() public {
        poolManager = new MockPoolManager();
        brevisZKCoprocessor = new MockBrevisZKCoprocessor();
        
        hook = new CLIdentityHook();
        hook.initialize(IPoolManager(address(poolManager)), IBrevisZKCoprocessor(address(brevisZKCoprocessor)));
        
        vm.prank(ADMIN);
        hook.grantRole(hook.VERIFIER_ROLE(), ADMIN);
    }

    function testVerifyIdentity() public {
        vm.prank(ADMIN);
        hook.verifyIdentity(USER, abi.encode("valid_proof"));
        
        assertTrue(hook.isVerified(USER));
        assertEq(uint(hook.getIdentityLevel(USER)), uint(IdentityUtils.VerificationLevel.Premium));
    }

    function testBeforeSwap() public {
        vm.prank(ADMIN);
        hook.verifyIdentity(USER, abi.encode("valid_proof"));

        PoolKey memory poolKey;
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: 100,
            sqrtPriceLimitX96: 0
        });

        vm.prank(USER);
        bytes4 selector = hook.beforeSwap(USER, poolKey, params, "");
        assertEq(selector, ICLIdentityHook.beforeSwap.selector);
    }

    function testBeforeSwapUnverified() public {
        PoolKey memory poolKey;
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: 100,
            sqrtPriceLimitX96: 0
        });

        vm.expectRevert("Sender not verified");
        hook.beforeSwap(USER, poolKey, params, "");
    }


}