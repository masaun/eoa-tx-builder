// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../src/EoaAuth.sol";
import "../src/utils/Verifier.sol";
import "../src/utils/ECDSAOwnedDKIMRegistry.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./helpers/StructHelper.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract EoaAuthTest is StructHelper {
    function setUp() public override {
        super.setUp();

        vm.startPrank(deployer);
        eoaAuth.initialize(deployer, deployer);
        //eoaAuth.initialize(deployer, accountSalt, deployer);
        vm.expectEmit(true, false, false, false);
        emit EoaAuth.VerifierUpdated(address(verifier));
        eoaAuth.updateVerifier(address(verifier));
        vm.expectEmit(true, false, false, false);
        emit EoaAuth.DKIMRegistryUpdated(address(dkim));
        eoaAuth.updateDKIMRegistry(address(dkim));
        vm.stopPrank();
    }

    function testDkimRegistryAddr() public view {
        address dkimAddr = eoaAuth.dkimRegistryAddr();
        assertEq(dkimAddr, address(dkim));
    }

    function testVerifierAddr() public view {
        address verifierAddr = eoaAuth.verifierAddr();
        assertEq(verifierAddr, address(verifier));
    }

    function testUpdateDKIMRegistryToECDSA() public {
        assertEq(eoaAuth.dkimRegistryAddr(), address(dkim));

        vm.startPrank(deployer);
        ECDSAOwnedDKIMRegistry newDKIM;
        {
            ECDSAOwnedDKIMRegistry dkimImpl = new ECDSAOwnedDKIMRegistry();
            ERC1967Proxy dkimProxy = new ERC1967Proxy(
                address(dkimImpl),
                abi.encodeCall(dkimImpl.initialize, (msg.sender, msg.sender))
            );
            newDKIM = ECDSAOwnedDKIMRegistry(address(dkimProxy));
        }
        vm.expectEmit(true, false, false, false);
        emit EoaAuth.DKIMRegistryUpdated(address(newDKIM));
        eoaAuth.updateDKIMRegistry(address(newDKIM));
        vm.stopPrank();

        assertEq(eoaAuth.dkimRegistryAddr(), address(newDKIM));
    }

    function testExpectRevertUpdateDKIMRegistryInvalidDkimRegistryAddress()
        public
    {
        assertEq(eoaAuth.dkimRegistryAddr(), address(dkim));

        vm.startPrank(deployer);
        vm.expectRevert(bytes("invalid dkim registry address"));
        eoaAuth.updateDKIMRegistry(address(0));
        vm.stopPrank();
    }

    function testUpdateVerifier() public {
        assertEq(eoaAuth.verifierAddr(), address(verifier));

        vm.startPrank(deployer);
        Verifier newVerifier = new Verifier();
        vm.expectEmit(true, false, false, false);
        emit EoaAuth.VerifierUpdated(address(newVerifier));
        eoaAuth.updateVerifier(address(newVerifier));
        vm.stopPrank();

        assertEq(eoaAuth.verifierAddr(), address(newVerifier));
    }

    function testExpectRevertUpdateVerifierInvalidVerifierAddress() public {
        assertEq(eoaAuth.verifierAddr(), address(verifier));

        vm.startPrank(deployer);
        vm.expectRevert(bytes("invalid verifier address"));
        eoaAuth.updateVerifier(address(0));
        vm.stopPrank();
    }

    function testAuthEoa() public {
        vm.startPrank(deployer);
        EoaAuthMsg memory eoaAuthMsg = buildEoaAuthMsg();
        vm.stopPrank();

        assertEq(
            eoaAuth.usedNullifiers(eoaAuthMsg.proof.eoaNullifier),
            false
        );
        assertEq(eoaAuth.lastTimestamp(), 0);

        vm.startPrank(deployer);
        vm.expectEmit(true, true, true, true);
        emit EoaAuth.EoaAuthed(
            eoaAuthMsg.proof.eoaNullifier
        );
        eoaAuth.authEoa(eoaAuthMsg);
        vm.stopPrank();

        assertEq(
            eoaAuth.usedNullifiers(eoaAuthMsg.proof.eoaNullifier),
            true
        );
        assertEq(eoaAuth.lastTimestamp(), eoaAuthMsg.proof.timestamp);
    }

    function testExpectRevertAuthEoaCallerIsNotTheModule() public {
        EoaAuthMsg memory eoaAuthMsg = buildEoaAuthMsg();

        assertEq(
            eoaAuth.usedNullifiers(eoaAuthMsg.proof.eoaNullifier),
            false
        );
        assertEq(eoaAuth.lastTimestamp(), 0);

        vm.expectRevert("only controller");
        eoaAuth.authEoa(eoaAuthMsg);
    }

    function testExpectRevertAuthEoaInvalidDkimPublicKeyHash() public {
        vm.startPrank(deployer);
        EoaAuthMsg memory eoaAuthMsg = buildEoaAuthMsg();
        vm.stopPrank();

        assertEq(
            eoaAuth.usedNullifiers(eoaAuthMsg.proof.eoaNullifier),
            false
        );
        assertEq(eoaAuth.lastTimestamp(), 0);

        vm.startPrank(deployer);
        //eoaAuthMsg.proof.domainName = "invalid.com";
        vm.expectRevert(bytes("invalid dkim public key hash"));
        eoaAuth.authEoa(eoaAuthMsg);
        vm.stopPrank();
    }

    function testExpectRevertAuthEoaNullifierAlreadyUsed() public {
        vm.startPrank(deployer);
        EoaAuthMsg memory eoaAuthMsg = buildEoaAuthMsg();
        vm.stopPrank();

        assertEq(
            eoaAuth.usedNullifiers(eoaAuthMsg.proof.eoaNullifier),
            false
        );
        assertEq(eoaAuth.lastTimestamp(), 0);

        vm.startPrank(deployer);
        eoaAuth.authEoa(eoaAuthMsg);
        vm.expectRevert(bytes("eoa nullifier already used"));
        eoaAuth.authEoa(eoaAuthMsg);
        vm.stopPrank();
    }

    function testExpectRevertAuthEoaInvalidAccountSalt() public {
        vm.startPrank(deployer);
        EoaAuthMsg memory eoaAuthMsg = buildEoaAuthMsg();
        vm.stopPrank();

        assertEq(
            eoaAuth.usedNullifiers(eoaAuthMsg.proof.eoaNullifier),
            false
        );
        assertEq(eoaAuth.lastTimestamp(), 0);

        vm.startPrank(deployer);
        eoaAuth.authEoa(eoaAuthMsg);
        vm.stopPrank();
    }

    function testExpectRevertAuthEoaInvalidTimestamp() public {
        vm.startPrank(deployer);
        // _testInsertCommandTemplate();
        EoaAuthMsg memory eoaAuthMsg = buildEoaAuthMsg();
        eoaAuth.authEoa(eoaAuthMsg);
        vm.stopPrank();

        assertEq(
            eoaAuth.usedNullifiers(eoaAuthMsg.proof.eoaNullifier),
            true
        );
        assertEq(eoaAuth.lastTimestamp(), eoaAuthMsg.proof.timestamp);

        vm.startPrank(deployer);
        eoaAuthMsg.proof.eoaNullifier = 0x0;
        eoaAuthMsg.proof.timestamp = 1694989812;
        vm.expectRevert(bytes("invalid timestamp"));
        eoaAuth.authEoa(eoaAuthMsg);

        vm.stopPrank();
    }

    function testSetTimestampCheckEnabled() public {
        vm.startPrank(deployer);

        assertTrue(eoaAuth.timestampCheckEnabled());
        vm.expectEmit(true, false, false, false);
        emit EoaAuth.TimestampCheckEnabled(false);
        eoaAuth.setTimestampCheckEnabled(false);
        assertFalse(eoaAuth.timestampCheckEnabled());

        vm.stopPrank();
    }

    function testExpectRevertSetTimestampCheckEnabled() public {
        vm.expectRevert("only controller");
        eoaAuth.setTimestampCheckEnabled(false);
    }

    function testUpgradeEoaAuth() public {
        vm.startPrank(deployer);

        // Deploy new implementation
        EoaAuth newImplementation = new EoaAuth();

        // Execute upgrade using proxy
        // Upgrade implementation through proxy contract
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(eoaAuth),
            abi.encodeCall(
                eoaAuth.initialize,
                (deployer, deployer)
            )
        );
        EoaAuth eoaAuthProxy = EoaAuth(payable(proxy));

        vm.stopPrank();
    }
}
