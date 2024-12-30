pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";
include "@zk-email/circuits/email-verifier.circom"; /// @dev - The "EmailVerifier" template is implemented here.


// Verify email from user (sender) and extract a command in the email body, timestmap, recipient email (commitment), etc.
// * n - the number of bits in each chunk of the RSA public key (modulust)
// * k - the number of chunks in the RSA public key (n * k > 2048)
// * max_header_bytes - max number of bytes in the email header
// * max_body_bytes - max number of bytes in the email body
// * max_command_bytes - max number of bytes in the command
// * recipient_enabled - whether the email address commitment of the recipient = email address in the subject is exposed
// * is_qp_encoded - whether the email body is qp encoded
template EoaAuth(k) {
    //var email_max_bytes = email_max_bytes_const();

    signal input public_key[k]; // RSA public key (modulus), k parts of n bits each.
    signal input signature[k]; // RSA signature, k parts of n bits each.

    signal output public_key_hash;
    signal output timestamp;
    
    // Verify EOA Signature
    component eoa_verifier = EoaVerifier(max_header_bytes, max_body_bytes, n, k, 0, 0, 0, is_qp_encoded); /// @dev - include => component (NOTE: The "EmailVerifier" template is implemented in the "@zk-email/circuits/email-verifier.circom")
    eoa_verifier.pubkey <== public_key;
    eoa_verifier.signature <== signature;
    public_key_hash <== eoa_verifier.pubkeyHash;   
}