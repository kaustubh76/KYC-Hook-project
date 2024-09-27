// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IBrevisZKCoprocessor.sol";

contract MockBrevisZKCoprocessor is IBrevisZKCoprocessor {
    bytes private constant MOCK_PUBLIC_PARAMS = hex"0123456789abcdef";

    function verifyProof(bytes calldata proof) external pure override returns (bool isValid) {
        // For testing purposes, we'll consider a proof valid if it's not empty
        return proof.length > 0;
    }

    function generateProof(bytes calldata input) external pure override returns (bytes memory proof) {
        // For testing purposes, we'll just return the input as the "proof"
        return input;
    }

    function getPublicParameters() external pure override returns (bytes memory params) {
        return MOCK_PUBLIC_PARAMS;
    }
}