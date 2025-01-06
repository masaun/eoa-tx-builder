import fs from "fs";
// import { promisify } from "util";
// const relayerUtils = require("@zk-email/relayer-utils");

let account;
let guardian;

export async function genEoaCircuitInput(
    /// No parameter
): Promise<{
    account: string;  /// @dev - signal input
    guardian: string; /// @dev - signal input
}> {
    // const emailRaw = await promisify(fs.readFile)(emailFilePath, "utf8");
    // const jsonStr = await relayerUtils.genEmailCircuitInput(
    //     emailRaw,
    //     accountCode,
    //     options
    // );
    // return JSON.parse(jsonStr);

    account = "test address"
    guardian = "test address"
    
    return account, guardian;
}
