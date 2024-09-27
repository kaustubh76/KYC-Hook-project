// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBrevisZKCoprocessor.sol";

contract ZKProofGenerator is Ownable {
    IBrevisZKCoprocessor public brevisZKCoprocessor;

    event ZKCoprocessorUpdated(address newCoprocessor);

    constructor(address _brevisZKCoprocessor) {
        brevisZKCoprocessor = IBrevisZKCoprocessor(_brevisZKCoprocessor);
    }

    function generateIdentityProof(bytes calldata identityData) external view returns (bytes memory proof) {
        bytes memory input = abi.encodePacked(msg.sender, identityData);
        return brevisZKCoprocessor.generateProof(input);
    }

    function verifyIdentityProof(address user, bytes calldata proof) external view returns (bool isValid) {
        return brevisZKCoprocessor.verifyProof(proof);
    }

    function getPublicParameters() external view returns (bytes memory params) {
        return brevisZKCoprocessor.getPublicParameters();
    }

    function updateZKCoprocessor(address newCoprocessor) external onlyOwner {
        brevisZKCoprocessor = IBrevisZKCoprocessor(newCoprocessor);
        emit ZKCoprocessorUpdated(newCoprocessor);
    }
}