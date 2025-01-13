pragma circom 2.1.6;

include "./eoa-verifier.circom"; /// @dev - The "EoaVerifier" template is implemented here.


// Verify an EOA from user (sender)
template EoaAuth() {
    signal input account;     /// @dev - Privately stored via the input.json (to may be generated on FE)
    signal input guardian;    /// @dev - Privately stored via the input.json (to may be generated on FE)

    signal output accountPublicKey;  /// @dev - a "Public" signal

    accountPublicKey <== account;    /// @notice - In this case, the prameters in the SC to be generated will be a "proof" + "accountPublicKey" (= public signal)

    accountPublicKey === account;    /// @dev - Constraint
}