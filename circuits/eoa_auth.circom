pragma circom 2.1.6;

include "./eoa_auth_template.circom";

component main = EoaAuth();                                 /// @dev - Main component to be executed. (Any input signals can be "private")
//component main {public [guardianStorageKey]} = EoaAuth(); /// @dev - Main component to be executed. ("guardianStorageKey" can be "public" (= "revealed"))
