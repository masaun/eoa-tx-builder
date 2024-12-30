pragma circom 2.1.6;

include "./eoa_auth_template.circom";

component main = EoaAuth(121, 17); /// @dev - Main component to be executed.


// Verify email from user (sender) and extract a command in the email body, timestmap, recipient email (commitment), etc.
// * n - the number of bits in each chunk of the RSA public key (modulust)
// * k - the number of chunks in the RSA public key (n * k > 2048)