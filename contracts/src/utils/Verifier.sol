// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IGroth16Verifier.sol"; /// @audit info - Groth16Verifier SC
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IVerifier, EmailProof} from "../interfaces/IVerifier.sol";

contract Verifier is OwnableUpgradeable, UUPSUpgradeable, IVerifier { /// @audit info - This SC is generated by ZK circuit (in Circom)
    IGroth16Verifier groth16Verifier;  /// @audit info - Groth16Verifier SC

    uint256 public constant DOMAIN_FIELDS = 9;
    uint256 public constant DOMAIN_BYTES = 255;
    uint256 public constant COMMAND_FIELDS = 20;
    uint256 public constant COMMAND_BYTES = 605;

    // Base field size
    uint256 constant q =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    constructor() {}

    /// @notice Initialize the contract with the initial owner and deploy Groth16Verifier
    /// @param _initialOwner The address of the initial owner
    function initialize(
        address _initialOwner,
        address _groth16Verifier
    ) public initializer {
        __Ownable_init(_initialOwner);
        groth16Verifier = IGroth16Verifier(_groth16Verifier);
    }

    function verifyEoaProof(  /// @audit info - This function is called in the EoaAuth# verifyEmailProof() to validate ~.
        EoaProof memory proof
    ) public view returns (bool) {
        return groth16Verifier.verifyProof(proof); /// @audit info - Groth16Verifier# verifyProof()
    }

    function updateGroth16Verifier(address _groth16Verifier) public onlyOwner {
        require(
            _groth16Verifier != address(0),
            "New groth16Verifier address is invalid"
        );
        groth16Verifier = IGroth16Verifier(_groth16Verifier);
    }

    function _packBytes2Fields(
        bytes memory _bytes,
        uint256 _paddedSize
    ) private pure returns (uint256[] memory) {
        uint256 remain = _paddedSize % 31;
        uint256 numFields = (_paddedSize - remain) / 31;
        if (remain > 0) {
            numFields += 1;
        }
        uint256[] memory fields = new uint[](numFields);
        uint256 idx = 0;
        uint256 byteVal = 0;
        for (uint256 i = 0; i < numFields; i++) {
            for (uint256 j = 0; j < 31; j++) {
                idx = i * 31 + j;
                if (idx >= _paddedSize) {
                    break;
                }
                if (idx >= _bytes.length) {
                    byteVal = 0;
                } else {
                    byteVal = uint256(uint8(_bytes[idx]));
                }
                if (j == 0) {
                    fields[i] = byteVal;
                } else {
                    fields[i] += (byteVal << (8 * j));
                }
            }
        }
        return fields;
    }

    /// @notice Upgrade the implementation of the proxy.
    /// @param newImplementation Address of the new implementation.
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
