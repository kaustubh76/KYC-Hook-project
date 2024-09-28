// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title ZKProofUtils
 * @dev Library for handling zero-knowledge proof operations
 */
library ZKProofUtils {
    using ECDSA for bytes32;

    struct ZKProof {
        uint256[] publicInputs;
        bytes proof;
    }

    event ProofVerified(address indexed verifier, bytes32 proofHash);
    event ProofRejected(address indexed verifier, bytes32 proofHash);

    error InvalidProof();
    error ProofAlreadyUsed();
    error VerificationFailed();

    /**
     * @dev Verifies a zero-knowledge proof
     * @param _proof The ZK proof to verify
     * @param verifierAddress The address of the verifier contract
     * @return bool True if the proof is valid
     */
    function verifyProof(ZKProof memory _proof, address verifierAddress) internal returns (bool) {
        (bool success, bytes memory result) = verifierAddress.call(
            abi.encodeWithSignature("verifyProof(uint256[],bytes)", _proof.publicInputs, _proof.proof)
        );
        
        if (!success) {
            emit ProofRejected(verifierAddress, hashProof(_proof));
            revert VerificationFailed();
        }
        
        bool isValid = abi.decode(result, (bool));
        
        if (isValid) {
            emit ProofVerified(verifierAddress, hashProof(_proof));
        } else {
            emit ProofRejected(verifierAddress, hashProof(_proof));
        }
        
        return isValid;
    }

    /**
     * @dev Hashes a ZK proof
     * @param _proof The proof to hash
     * @return bytes32 The keccak256 hash of the proof
     */
    function hashProof(ZKProof memory _proof) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_proof.publicInputs, _proof.proof));
    }

    /**
     * @dev Checks if a proof has been used before
     * @param proofHash The hash of the proof to check
     * @param usedProofs A mapping of used proof hashes
     * @return bool True if the proof is fresh (unused)
     */
    function isProofFresh(bytes32 proofHash, mapping(bytes32 => bool) storage usedProofs) internal view returns (bool) {
        return !usedProofs[proofHash];
    }

    /**
     * @dev Marks a proof as used
     * @param proofHash The hash of the proof to mark as used
     * @param usedProofs A mapping of used proof hashes
     */
    function markProofAsUsed(bytes32 proofHash, mapping(bytes32 => bool) storage usedProofs) internal {
        usedProofs[proofHash] = true;
    }

    /**
     * @dev Extracts public inputs from a ZK proof
     * @param _proof The proof to extract inputs from
     * @return uint256[] The public inputs
     */
    function extractPublicInputs(ZKProof memory _proof) internal pure returns (uint256[] memory) {
        return _proof.publicInputs;
    }

    /**
     * @dev Verifies a signature on a proof hash
     * @param proofHash The hash of the proof
     * @param signature The signature to verify
     * @return address The address that signed the proof
     */
    function recoverProofSigner(bytes32 proofHash, bytes memory signature) internal pure returns (address) {
        return proofHash.toEthSignedMessageHash().recover(signature);
    }
}