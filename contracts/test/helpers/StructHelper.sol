// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./DeploymentHelper.sol";

contract StructHelper is DeploymentHelper {
    function buildEoaAuthMsg()
        public
        returns (EoaAuthMsg memory eoaAuthMsg)
    {
        bytes[] memory commandParams = new bytes[](2);
        commandParams[0] = abi.encode(1 ether);
        commandParams[1] = abi.encode(
            "0x0000000000000000000000000000000000000020"
        );

        EoaProof memory eoaProof = EoaProof({
            domainName: "gmail.com",
            publicKeyHash: publicKeyHash,
            timestamp: 1694989812,
            maskedCommand: "Send 1 ETH to 0x0000000000000000000000000000000000000020",
            eoaNullifier: eoaNullifier,
            accountSalt: accountSalt,
            isCodeExist: true,
            proof: mockProof
        });

        eoaAuthMsg = EoaAuthMsg({
            templateId: templateId,
            commandParams: commandParams,
            skippedCommandPrefix: 0,
            proof: eoaProof
        });

        vm.mockCall(
            address(verifier),
            abi.encodeCall(Verifier.verifyEoaProof, (eoaProof)),
            abi.encode(true)
        );
    }
}
