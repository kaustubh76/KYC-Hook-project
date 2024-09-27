// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBrevisZKCoprocessor {
    /// @notice Verifies a zero-knowledge proof
    /// @param proof The zero-knowledge proof to verify
    /// @return isValid True if the proof is valid
    function verifyProof(bytes calldata proof) external view returns (bool isValid);

    /// @notice Generates a zero-knowledge proof
    /// @param input The input data for generating the proof
    /// @return proof The generated zero-knowledge proof
    function generateProof(bytes calldata input) external view returns (bytes memory proof);

    /// @notice Gets the public parameters for the zero-knowledge proof system
    /// @return params The public parameters
    function getPublicParameters() external view returns (bytes memory params);
}