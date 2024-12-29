pragma circom 2.1.6;

include "./eoa_auth_template.circom";

component main = EoaAuth(121, 17, 1024, 1024, 605, 0, 1); /// @dev - Main component to be executed.


// Verify email from user (sender) and extract a command in the email body, timestmap, recipient email (commitment), etc.
// * n - the number of bits in each chunk of the RSA public key (modulust)
// * k - the number of chunks in the RSA public key (n * k > 2048)
// * max_header_bytes - max number of bytes in the email header
// * max_body_bytes - max number of bytes in the email body
// * max_command_bytes - max number of bytes in the command
// * recipient_enabled - whether the email address commitment of the recipient = email address in the subject is exposed
// * is_qp_encoded - whether the email body is qp encoded