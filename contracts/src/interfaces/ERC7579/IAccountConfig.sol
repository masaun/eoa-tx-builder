interface IAccountConfig {
    /**
     * @dev Returns the account id of the smart account
     * @return accountImplementationId the account id of the smart account
     *
     * MUST return a non-empty string
     * The accountId SHOULD be structured like so:
     *        "vendorname.accountname.semver"
     * The id SHOULD be unique across all smart accounts
     */
    function accountId() external view returns (string memory accountImplementationId);

    /**
     * @dev Function to check if the account supports a certain execution mode (see above)
     * @param encodedMode the encoded mode
     *
     * MUST return true if the account supports the mode and false otherwise
     */
    function supportsExecutionMode(bytes32 encodedMode) external view returns (bool);

    /**
     * @dev Function to check if the account supports a certain module typeId
     * @param moduleTypeId the module type ID according to the ERC-7579 spec
     *
     * MUST return true if the account supports the module type and false otherwise
     */
    function supportsModule(uint256 moduleTypeId) external view returns (bool);
}