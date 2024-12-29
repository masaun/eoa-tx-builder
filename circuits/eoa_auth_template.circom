pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/poseidon.circom";
include "@zk-email/circuits/email-verifier.circom"; /// @dev - The "EmailVerifier" template is implemented here.
include "@zk-email/circuits/utils/regex.circom";
include "@zk-email/circuits/utils/functions.circom";
include "./utils/constants.circom";
include "./utils/account_salt.circom";
include "./utils/hash_sign.circom";
include "./utils/email_nullifier.circom";
include "./utils/bytes2ints.circom";
include "./utils/digit2int.circom";
include "./utils/hex2int.circom";
include "./utils/email_addr_commit.circom";
include "./regexes/invitation_code_with_prefix_regex.circom";
include "./regexes/invitation_code_regex.circom";
include "./regexes/command_regex.circom";
include "./regexes/forced_subject_regex.circom";
include "@zk-email/zk-regex-circom/circuits/common/from_addr_regex.circom";
include "@zk-email/zk-regex-circom/circuits/common/email_addr_regex.circom";
include "@zk-email/zk-regex-circom/circuits/common/email_domain_regex.circom";
include "@zk-email/zk-regex-circom/circuits/common/subject_all_regex.circom";
include "@zk-email/zk-regex-circom/circuits/common/timestamp_regex.circom";

// Verify email from user (sender) and extract a command in the email body, timestmap, recipient email (commitment), etc.
// * n - the number of bits in each chunk of the RSA public key (modulust)
// * k - the number of chunks in the RSA public key (n * k > 2048)
// * max_header_bytes - max number of bytes in the email header
// * max_body_bytes - max number of bytes in the email body
// * max_command_bytes - max number of bytes in the command
// * recipient_enabled - whether the email address commitment of the recipient = email address in the subject is exposed
// * is_qp_encoded - whether the email body is qp encoded
template EoaAuth(n, k, max_header_bytes, max_body_bytes, max_command_bytes, recipient_enabled, is_qp_encoded) {
    var email_max_bytes = email_max_bytes_const();

    signal input padded_header[max_header_bytes]; // email data (only header part)
    signal input padded_header_len; // length of in email data including the padding
    signal input public_key[k]; // RSA public key (modulus), k parts of n bits each.
    signal input signature[k]; // RSA signature, k parts of n bits each.

    signal output domain_name[domain_field_len];
    signal output public_key_hash;
    signal output email_nullifier;
    signal output timestamp;
    
    // Verify Email (-> EOA) Signature
    component email_verifier = EoaVerifier(max_header_bytes, max_body_bytes, n, k, 0, 0, 0, is_qp_encoded); /// @dev - include => component (NOTE: The "EmailVerifier" template is implemented in the "@zk-email/circuits/email-verifier.circom")
    email_verifier.emailHeader <== padded_header;
    email_verifier.emailHeaderLength <== padded_header_len;
    email_verifier.pubkey <== public_key;
    email_verifier.signature <== signature;
    email_verifier.bodyHashIndex <== body_hash_idx;
    email_verifier.precomputedSHA <== precomputed_sha;
    email_verifier.emailBody <== padded_body;
    email_verifier.emailBodyLength <== padded_body_len;
    if (is_qp_encoded == 1) {
        email_verifier.decodedEmailBodyIn <== padded_cleaned_body;
    }
    public_key_hash <== email_verifier.pubkeyHash;
    
}