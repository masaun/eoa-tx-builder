pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";
include "./eoa-verifier.circom"; /// @dev - The "EoaVerifier" template is implemented here.


// Verify email from user (sender) and extract a command in the email body, timestmap, recipient email (commitment), etc.
// * n - the number of bits in each chunk of the RSA public key (modulust)
// * k - the number of chunks in the RSA public key (n * k > 2048)
template EoaAuth(n, k) {
    //var email_max_bytes = email_max_bytes_const();

    signal input public_key[k]; // RSA public key (modulus), k parts of n bits each.
    signal input signature[k]; // RSA signature, k parts of n bits each.

    signal output public_key_hash;
    signal output timestamp;
    
    // Verify EOA Signature
    component eoa_verifier = EoaVerifier(k); /// @dev - include => component (NOTE: The "EmailVerifier" template is implemented in the "@zk-email/circuits/email-verifier.circom")
    eoa_verifier.pubkey <== public_key;
    eoa_verifier.signature <== signature;
    public_key_hash <== eoa_verifier.pubkeyHash;   
}