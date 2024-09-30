// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./../lib/forge-std/src/Script.sol";
import "../src/CLIdentityHook.sol";
import "../src/BinIdentityHook.sol";
import "../src/BrevisZKCoprocessor.sol";
import "../src/ChallengeResponseVerifier.sol";
import "../src/ReputationSystem.sol";
import "../src/AdminDashboard.sol";
import "./../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "./../lib/openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";

contract DeployIdentityHooks is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address brevisCoprocessor = vm.envAddress("BREVIS_COPROCESSOR_ADDRESS");
        address clPoolManager = vm.envAddress("CL_POOL_MANAGER_ADDRESS");
        address binPoolManager = vm.envAddress("BIN_POOL_MANAGER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy shared components
        BrevisZKAdapter brevisAdapter = new BrevisZKAdapter(brevisCoprocessor);
        ChallengeResponseVerifier challengeVerifier = new ChallengeResponseVerifier();
        ReputationSystem reputationSystem = new ReputationSystem();

        // Deploy ProxyAdmin
        ProxyAdmin proxyAdmin = new ProxyAdmin();

        // Deploy CL Identity Hook
        CLIdentityHook clHookImplementation = new CLIdentityHook();
        TransparentUpgradeableProxy clHookProxy = new TransparentUpgradeableProxy(
            address(clHookImplementation),
            address(proxyAdmin),
            abi.encodeWithSelector(
                CLIdentityHook.initialize.selector,
                clPoolManager,
                address(brevisAdapter),
                address(challengeVerifier),
                address(reputationSystem)
            )
        );
        CLIdentityHook clHook = CLIdentityHook(address(clHookProxy));

        // Deploy Bin Identity Hook
        BinIdentityHook binHookImplementation = new BinIdentityHook();
        TransparentUpgradeableProxy binHookProxy = new TransparentUpgradeableProxy(
            address(binHookImplementation),
            address(proxyAdmin),
            abi.encodeWithSelector(
                BinIdentityHook.initialize.selector,
                binPoolManager,
                address(brevisAdapter),
                address(challengeVerifier),
                address(reputationSystem)
            )
        );
        BinIdentityHook binHook = BinIdentityHook(address(binHookProxy));

        // Deploy AdminDashboard
        AdminDashboard adminDashboard = new AdminDashboard(clHook, binHook, reputationSystem);

        // Setup roles
        bytes32 updaterRole = reputationSystem.UPDATER_ROLE();
        reputationSystem.grantRole(updaterRole, address(clHook));
        reputationSystem.grantRole(updaterRole, address(binHook));

        bytes32 challengeIssuerRole = challengeVerifier.CHALLENGE_ISSUER_ROLE();
        challengeVerifier.grantRole(challengeIssuerRole, address(clHook));
        challengeVerifier.grantRole(challengeIssuerRole, address(binHook));

        console.log("BrevisZKAdapter deployed at:", address(brevisAdapter));
        console.log("ChallengeResponseVerifier deployed at:", address(challengeVerifier));
        console.log("ReputationSystem deployed at:", address(reputationSystem));
        console.log("CLIdentityHook deployed at:", address(clHook));
        console.log("BinIdentityHook deployed at:", address(binHook));
        console.log("ProxyAdmin deployed at:", address(proxyAdmin));
        console.log("AdminDashboard deployed at:", address(adminDashboard));

        vm.stopBroadcast();
    }
}