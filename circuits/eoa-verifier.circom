pragma circom 2.1.6;

include "./lib/circomlib/circuits/bitify.circom";
include "./lib/circomlib/circuits/poseidon.circom";
// include "circomlib/circuits/bitify.circom";
// include "circomlib/circuits/poseidon.circom";
include "@zk-email/zk-regex-circom/circuits/common/body_hash_regex.circom";
include "./lib/base64.circom";
include "./lib/rsa.circom";
include "./lib/sha.circom";
include "./utils/array.circom";
include "./utils/regex.circom";
include "./utils/hash.circom";
include "./utils/bytes.circom";
include "./helpers/remove-soft-line-breaks.circom";

/// @title EoaVerifier
/// @notice Circuit to verify an EOA signature as per DKIM standard.
/// @notice Verifies the signature is valid for the given header and pubkey, and the hash of the body matches the hash in the header.
/// @notice This cicuit only verifies signature as per `rsa-sha256` algorithm.
template EoaVerifier(k) {

}