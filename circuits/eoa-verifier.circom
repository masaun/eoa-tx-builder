pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/poseidon.circom";
include "@zk-email/zk-regex-circom/circuits/common/body_hash_regex.circom";
include "./lib/base64.circom";
include "./lib/rsa.circom";
include "./lib/sha.circom";
include "./utils/array.circom";
include "./utils/regex.circom";
include "./utils/hash.circom";
include "./utils/bytes.circom";
include "./helpers/remove-soft-line-breaks.circom";

/// @title EmailVerifier
/// @notice Circuit to verify email signature as per DKIM standard.
/// @notice Verifies the signature is valid for the given header and pubkey, and the hash of the body matches the hash in the header.
/// @notice This cicuit only verifies signature as per `rsa-sha256` algorithm.
/// @param maxHeadersLength Maximum length for the email header.
/// @param maxBodyLength Maximum length for the email body.
/// @param n Number of bits per chunk the RSA key is split into. Recommended to be 121.
/// @param k Number of chunks the RSA key is split into. Recommended to be 17.
/// @param ignoreBodyHashCheck Set 1 to skip body hash check in case data to prove/extract is only in the headers.
/// @param enableHeaderMasking Set 1 to turn on header masking.
/// @param enableBodyMasking Set 1 to turn on body masking.
/// @param removeSoftLineBreaks Set 1 to remove soft line breaks from the email body.
/// @input emailHeader[maxHeadersLength] Email headers that are signed (ones in `DKIM-Signature` header) as ASCII int[], padded as per SHA-256 block size.
/// @input emailHeaderLength Length of the email header including the SHA-256 padding.
/// @input pubkey[k] RSA public key split into k chunks of n bits each.
/// @input signature[k] RSA signature split into k chunks of n bits each.
/// @input emailBody[maxBodyLength] Email body after the precomputed SHA as ASCII int[], padded as per SHA-256 block size.
/// @input emailBodyLength Length of the email body including the SHA-256 padding.
/// @input bodyHashIndex Index of the body hash `bh` in the emailHeader.
/// @input precomputedSHA[32] Precomputed SHA-256 hash of the email body till the bodyHashIndex.
/// @input decodedEmailBodyIn[maxBodyLength] Decoded email body without soft line breaks.
/// @input mask[maxBodyLength] Mask for the email body.
/// @output pubkeyHash Poseidon hash of the pubkey - Poseidon(n/2)(n/2 chunks of pubkey with k*2 bits per chunk).
/// @output decodedEmailBodyOut[maxBodyLength] Decoded email body with soft line breaks removed.
/// @output maskedHeader[maxHeadersLength] Masked email header.
/// @output maskedBody[maxBodyLength] Masked email body.

template EoaVerifier(maxHeadersLength, maxBodyLength, n, k, ignoreBodyHashCheck, enableHeaderMasking, enableBodyMasking, removeSoftLineBreaks) {
