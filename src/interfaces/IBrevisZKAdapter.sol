// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import {IBrevisZKCoprocessor} from "./interfaces/IBrevisZKCoprocessor.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// /// @title Brevis ZK Adapter
// /// @notice Adapter contract for interacting with the Brevis ZK-Coprocessor
// /// @dev This contract verifies ZK proofs using the Brevis ZK-Coprocessor
// contract BrevisZKAdapter is Ownable {
//     IBrevisZKCoprocessor public brevisCoprocessor;

//     event ProofVerified(address indexed user, bool isValid);
//     event CoprocessorUpdated(address indexed oldCoprocessor, address indexed newCoprocessor);

//     error InvalidProof();
//     error CoprocessorCallFailed();

//     /// @notice Constructor to set the initial Brevis ZK-Coprocessor address
//     /// @param _brevisCoprocessor The address of the Brevis ZK-Coprocessor
//     constructor(address _brevisCoprocessor) Ownable(msg.sender) {
//         brevisCoprocessor = IBrevisZKCoprocessor(_brevisCoprocessor);
//     }

//     /// @notice Verifies a ZK proof for a user
//     /// @param user The address of the user the proof is for
//     /// @param zkProof The ZK proof to verify
//     /// @return isValid Boolean indicating if the proof is valid
//     function verifyProof(address user, bytes calldata zkProof) external returns (bool isValid) {
//         if (zkProof.length == 0) revert InvalidProof();

//         try brevisCoprocessor.verifyProof(zkProof) returns (bool result) {
//             isValid = result;
//         } catch {
//             revert CoprocessorCallFailed();
//         }

//         emit ProofVerified(user, isValid);
//     }

//     /// @notice Updates the address of the Brevis ZK-Coprocessor
//     /// @param newCoprocessor The new address of the Brevis ZK-Coprocessor
//     function updateCoprocessor(address newCoprocessor) external onlyOwner {
//         address oldCoprocessor = address(brevisCoprocessor);
//         brevisCoprocessor = IBrevisZKCoprocessor(newCoprocessor);
//         emit CoprocessorUpdated(oldCoprocessor, newCoprocessor);
//     }
// }