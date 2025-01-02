pragma circom 2.1.6;

include "./eoa-verifier.circom"; /// @dev - The "EoaVerifier" template is implemented here.


// Verify an EOA from user (sender) and extract a command in the email body, timestmap, recipient email (commitment), etc.
template EoaAuth() {
    signal input account;               /// @dev - Privately stored via the input.json 
    signal input guardianStorageKey;    /// @dev - Privately stored via the input.json 
    signal input guardianStorageValue;  /// @dev - Privately stored via the input.json 

    signal output guardianPublicKey;    /// @dev - Public

    guardianPublicKey <== guardianStorageKey; /// @dev - Constraint
}