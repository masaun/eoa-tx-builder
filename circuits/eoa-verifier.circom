pragma circom 2.1.6;

// include "./lib/circomlib/circuits/bitify.circom";
// include "./lib/circomlib/circuits/poseidon.circom";
// include "./lib/@zk-email/zk-regex-circom/circuits/common/body_hash_regex.circom";
// include "./lib/@zk-email/circuits/lib/base64.circom";
// include "./lib/@zk-email/circuits/lib/rsa.circom";
// include "./lib/@zk-email/circuits/lib/sha.circom";
// include "./lib/@zk-email/circuits/utils/array.circom";
// include "./lib/@zk-email/circuits/utils/regex.circom";
// include "./lib/@zk-email/circuits/utils/hash.circom";
// include "./lib/@zk-email/circuits/utils/bytes.circom";
// include "./lib/@zk-email/circuits/helpers/remove-soft-line-breaks.circom";

/// @title EoaVerifier
/// @notice Circuit to verify an EOA signature as per DKIM standard.
/// @notice Verifies the signature is valid for the given header and pubkey, and the hash of the body matches the hash in the header.
/// @notice This cicuit only verifies signature as per `rsa-sha256` algorithm.
template EoaVerifier(k) {

}