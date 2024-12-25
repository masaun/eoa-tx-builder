interface IExecution {
    /**
     * @dev Executes a transaction on behalf of the account.
     * @param mode The encoded execution mode of the transaction.
     * @param executionCalldata The encoded execution call data.
     *
     * MUST ensure adequate authorization control: e.g. onlyEntryPointOrSelf if used with ERC-4337
     * If a mode is requested that is not supported by the Account, it MUST revert
     */
    function execute(bytes32 mode, bytes calldata executionCalldata) external;

    /**
     * @dev Executes a transaction on behalf of the account.
     *         This function is intended to be called by Executor Modules
     * @param mode The encoded execution mode of the transaction.
     * @param executionCalldata The encoded execution call data.
     *
     * @return returnData An array with the returned data of each executed subcall
     *
     * MUST ensure adequate authorization control: i.e. onlyExecutorModule
     * If a mode is requested that is not supported by the Account, it MUST revert
     */
    function executeFromExecutor(bytes32 mode, bytes calldata executionCalldata)
        external
        returns (bytes[] memory returnData);
}