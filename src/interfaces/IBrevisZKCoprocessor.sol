// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IBrevisZKCoprocessor
 * @dev Interface for the Brevis ZK Coprocessor, which verifies zero-knowledge proofs
 */
interface IBrevisZKCoprocessor {
    /**
     * @dev Struct to hold verification parameters
     */
    struct VerificationParams {
        bytes32 verificationKey;
        uint256 maxProofSize;
        uint256 minProofSize;
    }

    /**
     * @dev Verifies a zero-knowledge proof
     * @param proof The encoded proof to be verified
     * @return bool Returns true if the proof is valid, false otherwise
     */
    function verifyProof(bytes calldata proof) external returns (bool);

    /**
     * @dev Batch verifies multiple zero-knowledge proofs
     * @param proofs An array of encoded proofs to be verified
     * @return results An array of boolean results, true for valid proofs, false otherwise
     */
    function batchVerifyProofs(bytes[] calldata proofs) external returns (bool[] memory results);

    /**
     * @dev Retrieves the current verification parameters
     * @return VerificationParams The current verification parameters
     */
    function getVerificationParams() external view returns (VerificationParams memory);

    /**
     * @dev Emitted when a proof is verified
     * @param prover The address that submitted the proof for verification
     * @param proofHash The keccak256 hash of the proof
     * @param result The result of the verification (true if valid, false otherwise)
     */
    event ProofVerified(address indexed prover, bytes32 indexed proofHash, bool result);

    /**
     * @dev Emitted when the verification parameters are updated
     * @param updater The address that updated the parameters
     * @param newParams The new verification parameters
     */
    event VerificationParametersUpdated(address indexed updater, VerificationParams newParams);

    /**
     * @dev Error thrown when an invalid proof is submitted
     * @param reason The reason for invalidity
     */
    error InvalidProof(string reason);

    /**
     * @dev Error thrown when an operation is attempted by an unauthorized address
     */
    error Unauthorized(address caller, bytes32 neededRole);

    /**
     * @dev Error thrown when the contract is paused
     */
    error ContractPaused();
}