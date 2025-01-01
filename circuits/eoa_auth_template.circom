pragma circom 2.1.6;

include "./lib/circomlib/circuits/bitify.circom";
include "./lib/circomlib/circuits/comparators.circom";
include "./lib/circomlib/circuits/poseidon.circom";
// include "circomlib/circuits/bitify.circom";
// include "circomlib/circuits/comparators.circom";
// include "circomlib/circuits/poseidon.circom";
include "./eoa-verifier.circom"; /// @dev - The "EoaVerifier" template is implemented here.


// Verify an EOA from user (sender) and extract a command in the email body, timestmap, recipient email (commitment), etc.
template EoaAuth() {
    signal input guardianStorageKey;    /// @dev - Privately stored via the input.json 
    signal input guardianStorageValue;  /// @dev - Privately stored via the input.json 

    signal output guardianPublicKey;    /// @dev - Public
    
    // Verify EOA Signature
    // component eoa_verifier = EoaVerifier(k); /// @dev - include => component (NOTE: The "EoalVerifier" template is implemented in the "@zk-email/circuits/eoa-verifier.circom")
    // eoa_verifier.pubkey <== public_key;
    // eoa_verifier.signature <== signature;
    // public_key_hash <== eoa_verifier.pubkeyHash;

    guardianPublicKey <== guardianStorageKey; /// @dev - Constraint
}