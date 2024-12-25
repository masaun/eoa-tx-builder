interface IHook is IModule {
    /**
     * @dev Called by the smart account before execution
     * @param msgSender the address that called the smart account
     * @param value the value that was sent to the smart account
     * @param msgData the data that was sent to the smart account
     *
     * MAY return arbitrary data in the `hookData` return value
     */
    function preCheck(address msgSender, uint256 value, bytes calldata msgData) external returns (bytes memory hookData);

    /**
     * @dev Called by the smart account after execution
     * @param hookData the data that was returned by the `preCheck` function
     *
     * MAY validate the `hookData` to validate transaction context of the `preCheck` function
     */
    function postCheck(bytes calldata hookData) external;
}