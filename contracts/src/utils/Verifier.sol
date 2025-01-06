// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IGroth16Verifier} from "../interfaces/circuits/IGroth16Verifier.sol"; /// @audit info - Groth16Verifier SC
import {IVerifier, EoaProof} from "../interfaces/circuits/IVerifier.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

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
        (
            uint256[2] memory pA,
            uint256[2][2] memory pB,
            uint256[2] memory pC
        ) = abi.decode(proof.proof, (uint256[2], uint256[2][2], uint256[2]));
        require(pA[0] < q && pA[1] < q, "invalid format of pA");
        require(
            pB[0][0] < q && pB[0][1] < q && pB[1][0] < q && pB[1][1] < q,
            "invalid format of pB"
        );
        require(pC[0] < q && pC[1] < q, "invalid format of pC");

        uint256[DOMAIN_FIELDS] memory pubSignals;
        //uint256[DOMAIN_FIELDS + COMMAND_FIELDS + 5] memory pubSignals;

        // uint256[] memory stringFields;
        // stringFields = _packBytes2Fields(bytes(proof.domainName), DOMAIN_BYTES);
        // for (uint256 i = 0; i < DOMAIN_FIELDS; i++) {
        //     pubSignals[i] = stringFields[i];
        // }
        pubSignals[DOMAIN_FIELDS] = uint256(proof.publicKeyHash);
        pubSignals[DOMAIN_FIELDS + 1] = uint256(proof.eoaNullifier);
        pubSignals[DOMAIN_FIELDS + 2] = uint256(proof.timestamp);
        // stringFields = _packBytes2Fields(
        //     bytes(proof.maskedCommand),
        //     COMMAND_BYTES
        // );
        // for (uint256 i = 0; i < COMMAND_FIELDS; i++) {
        //     pubSignals[DOMAIN_FIELDS + 3 + i] = stringFields[i];
        // }
        // pubSignals[DOMAIN_FIELDS + 3 + COMMAND_FIELDS] = uint256(
        //     proof.accountSalt
        // );
        // pubSignals[DOMAIN_FIELDS + 3 + COMMAND_FIELDS + 1] = proof.isCodeExist
        //     ? 1
        //     : 0;

        return groth16Verifier.verifyProof(pA, pB, pC, pubSignals); /// @audit info - Groth16Verifier# verifyProof()
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
