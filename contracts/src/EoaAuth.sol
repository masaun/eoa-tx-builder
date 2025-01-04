// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {EoaProof} from "./circuits/Verifier.sol"; /// @audit info - This EoaProof is imported from the Verifier.sol
import {IDKIMRegistry} from "@zk-email/contracts/DKIMRegistry.sol";
import {IVerifier, EoaProof} from "./interfaces/IVerifier.sol"; /// @audit info - This SC is generated by ZK circuit (in Circom)
import {CommandUtils} from "./libraries/CommandUtils.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/// @notice Struct to hold the email authentication/authorization message.
struct EoaAuthMsg {
    /// @notice The EOA proof containing the zk proof and other necessary information for the EOA verification by the Verifier contract.
    EoaProof proof; /// @audit info - This EoaProof is imported from the Verifier.sol
}

/// @title EOA Authentication/Authorization Contract
/// @notice This contract provides functionalities for the authentication of the email sender and the authentication of the message in the command part of the email body using DKIM and custom verification logic.
/// @dev Inherits from OwnableUpgradeable and UUPSUpgradeable for upgradeability and ownership management.
contract EoaAuth is OwnableUpgradeable, UUPSUpgradeable {
    /// The CREATE2 salt of this contract defined as a hash of an email address and an account code.
    bytes32 public accountSalt;
    /// An instance of the DKIM registry contract.
    IDKIMRegistry internal dkim;
    /// An instance of the Verifier contract.
    IVerifier internal verifier; /// @audit info - This SC is generated by ZK circuit (in Circom)
    /// An address of a controller contract, defining the command templates supported by this contract.
    address public controller;
    /// A mapping of the supported command templates associated with its ID.
    mapping(uint => string[]) public commandTemplates;
    /// A mapping of the hash of the authorized message associated with its `emailNullifier`.
    uint public lastTimestamp;
    /// The latest `timestamp` in the verified `EmailAuthMsg`.
    mapping(bytes32 => bool) public usedNullifiers;
    /// A boolean whether timestamp check is enabled or not.
    bool public timestampCheckEnabled;

    event DKIMRegistryUpdated(address indexed dkimRegistry);
    event VerifierUpdated(address indexed verifier);
    event CommandTemplateInserted(uint indexed templateId);
    event CommandTemplateUpdated(uint indexed templateId);
    event CommandTemplateDeleted(uint indexed templateId);
    event EoaAuthed(
        bytes32 indexed eoaNullifier,
        bytes32 indexed accountSalt,
        bool isCodeExist,
        uint templateId
    );
    event TimestampCheckEnabled(bool enabled);

    modifier onlyController() {
        require(msg.sender == controller, "only controller");
        _;
    }

    constructor() {}

    /// @notice Initialize the contract with an initial owner and an account salt.
    /// @param _initialOwner The address of the initial owner.
    /// @param _accountSalt The account salt to derive CREATE2 address of this contract.
    /// @param _controller The address of the controller contract.
    function initialize(
        address _initialOwner,
        bytes32 _accountSalt,
        address _controller
    ) public initializer {
        __Ownable_init(_initialOwner);
        accountSalt = _accountSalt;
        timestampCheckEnabled = true;
        controller = _controller;
    }

    /// @notice Returns the address of the DKIM registry contract.
    /// @return address The address of the DKIM registry contract.
    function dkimRegistryAddr() public view returns (address) {
        return address(dkim);
    }

    /// @notice Returns the address of the verifier contract.
    /// @return address The Address of the verifier contract.
    function verifierAddr() public view returns (address) {
        return address(verifier);
    }

    /// @notice Initializes the address of the DKIM registry contract.
    /// @param _dkimRegistryAddr The address of the DKIM registry contract.
    function initDKIMRegistry(address _dkimRegistryAddr) public onlyController {
        require(
            _dkimRegistryAddr != address(0),
            "invalid dkim registry address"
        );
        require(
            address(dkim) == address(0),
            "dkim registry already initialized"
        );
        dkim = IDKIMRegistry(_dkimRegistryAddr);
        emit DKIMRegistryUpdated(_dkimRegistryAddr);
    }

    /// @notice Initializes the address of the verifier contract.
    /// @param _verifierAddr The address of the verifier contract.
    function initVerifier(address _verifierAddr) public onlyController {
        require(_verifierAddr != address(0), "invalid verifier address");
        require(
            address(verifier) == address(0),
            "verifier already initialized"
        );
        verifier = IVerifier(_verifierAddr);
        emit VerifierUpdated(_verifierAddr);
    }

    /// @notice Updates the address of the DKIM registry contract.
    /// @param _dkimRegistryAddr The new address of the DKIM registry contract.
    function updateDKIMRegistry(address _dkimRegistryAddr) public onlyOwner {
        require(
            _dkimRegistryAddr != address(0),
            "invalid dkim registry address"
        );
        dkim = IDKIMRegistry(_dkimRegistryAddr);
        emit DKIMRegistryUpdated(_dkimRegistryAddr);
    }

    /// @notice Updates the address of the verifier contract.
    /// @param _verifierAddr The new address of the verifier contract.
    function updateVerifier(address _verifierAddr) public onlyOwner {
        require(_verifierAddr != address(0), "invalid verifier address");
        verifier = IVerifier(_verifierAddr);
        emit VerifierUpdated(_verifierAddr);
    }

    /// @notice Authenticate the EOA sender and authorize the message in the email command based on the provided email auth message.
    /// @dev This function can only be called by the controller contract.
    /// @param eoaAuthMsg The EOA auth message containing all necessary information for authentication and authorization.
    function authEoa(EoaAuthMsg memory eoaAuthMsg) public onlyController { /// @audit info - The "EoaAuthMsg" struct would include the "EoaProof proof" property, meaning that the proof (EmailProof) will be registered via this authEmail() function.
        require(
            dkim.isDKIMPublicKeyHashValid(
                eoaAuthMsg.proof.domainName,
                eoaAuthMsg.proof.publicKeyHash
            ) == true,
            "invalid dkim public key hash"
        );
        require(
            usedNullifiers[emailAuthMsg.proof.emailNullifier] == false,
            "email nullifier already used"
        );
        require(
            accountSalt == emailAuthMsg.proof.accountSalt,
            "invalid account salt"
        );

        require(
            verifier.verifyEoaProof(eoaAuthMsg.proof) == true, /// @audit info - Verifier# verifyEoaProof()
            "invalid EOA proof"
        );

        usedNullifiers[eoaAuthMsg.proof.eoaNullifier] = true;  // @audit info - State Update (= usedNullifiers)
        if (timestampCheckEnabled && eoaAuthMsg.proof.timestamp != 0) {
            lastTimestamp = eoaAuthMsg.proof.timestamp;
        }
        emit EoaAuthed(
            eoaAuthMsg.proof.emailNullifier,
            eoaAuthMsg.proof.accountSalt,
            eoaAuthMsg.proof.isCodeExist,
            eoaAuthMsg.templateId
        );
    }

    /// @notice Enables or disables the timestamp check.
    /// @dev This function can only be called by the controller.
    /// @param _enabled Boolean flag to enable or disable the timestamp check.
    function setTimestampCheckEnabled(bool _enabled) public onlyController {
        timestampCheckEnabled = _enabled;
        emit TimestampCheckEnabled(_enabled);
    }

    /// @notice Upgrade the implementation of the proxy.
    /// @param newImplementation Address of the new implementation.
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

}
