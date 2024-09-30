// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BinIdentityHook.sol";

contract BinIdentityHookTest is Test {
    BinIdentityHook public hook;
    address public constant ADMIN = address(0x1);
    address public constant USER = address(0x2);

    function setUp() public {
        binPoolManager = new MockBinPoolManager();
        brevisZKCoprocessor = new MockBrevisZKCoprocessor();
        
        hook = new BinIdentityHook();
        hook.initialize(IBinPoolManager(address(binPoolManager)), IBrevisZKCoprocessor(address(brevisZKCoprocessor)));
        
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

        BinPoolKey memory poolKey;
        IBinPoolManager.SwapParams memory params = IBinPoolManager.SwapParams({
            amount: 100,
            swapForY: true,
            to: USER
        });

        vm.prank(USER);
        bytes4 selector = hook.beforeSwap(USER, poolKey, params, "");
        assertEq(selector, IBinIdentityHook.beforeSwap.selector);
    }

    function testBeforeSwapUnverified() public {
        BinPoolKey memory poolKey;
        IBinPoolManager.SwapParams memory params = IBinPoolManager.SwapParams({
            amount: 100,
            swapForY: true,
            to: USER
        });

        vm.expectRevert("Sender not verified");
        hook.beforeSwap(USER, poolKey, params, "");
    }

}