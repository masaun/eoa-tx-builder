pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";
include "./eoa-verifier.circom"; /// @dev - The "EoaVerifier" template is implemented here.


// Verify an EOA from user (sender) and extract a command in the email body, timestmap, recipient email (commitment), etc.
template EoaAuth(_guardianStorageKey, _guardianStorageValue) {
    //var email_max_bytes = email_max_bytes_const();

    signal input guardianStorageKey;
    signal input guardianStorageValue;

    signal output 
    
    // Verify EOA Signature
    component eoa_verifier = EoaVerifier(k); /// @dev - include => component (NOTE: The "EmailVerifier" template is implemented in the "@zk-email/circuits/email-verifier.circom")
    eoa_verifier.pubkey <== public_key;
    eoa_verifier.signature <== signature;
    public_key_hash <== eoa_verifier.pubkeyHash;   
}