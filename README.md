# Ether EOA-auth SDK (EOA TX Buider)

## Technical Stack:
- The **Ether EOA-auth SDK (EOA TX Buider)** would be implemented with the following technical stack:
  - **ZK circuit**: written in [**`Circom`** and **`Snarkjs`**](https://docs.circom.io/) .
  - **Smart contract**: written in Solidity.

<br>

## Overview

- The **Ether EOA-auth SDK (EOA TX Buider)** would be used for **account recovery** as a secondary account recovery module in the [**ZK Email Recovery**](https://github.com/zkemail/email-recovery). (NOTE：At the moment, the [**Ether Email-auth SDK (Email TX Builder)**](https://github.com/zkemail/email-tx-builder) has been used as a primary account recovery module for the [**ZK Email Recovery**](https://github.com/zkemail/email-recovery). Basically, the **Ether EOA-auth SDK (EOA TX Buider)** would be assumed that it work with the [**Ether Email-auth SDK (Email TX Builder)**](https://github.com/zkemail/email-tx-builder) in the [**ZK Email Recovery**](https://github.com/zkemail/email-recovery))

- The **EOA TX Builder** would be the module:
  - which can generate a proof to prove that a given `account` address is associated with a `guardian` address. (NOTE：This proof is called a `EOA proof` in this repo)
  - which can generate the Verifier contract that can verify the proof.

<br>

## Integration with the `email-recovery` module

- The **Ether EOA-auth SDK (EOA TX Buider)** would be assumed that it work with the [**Ether Email-auth SDK (Email TX Builder)**](https://github.com/zkemail/email-tx-builder) in the [**ZK Email Recovery**](https://github.com/zkemail/email-recovery)
   - Integration summary and approach:
      https://github.com/masaun/email-recovery/blob/masaun_%2366_prototype-new-ERC7579-recovery-module/doc/summary-and-approach.md


<br>

## Installation

### ZK circuit (written in `Circom` and `Snarkjs`)

- 1/ Move to the `./circuits` directory
```shell
cd circuits
```

- 2/ Compiling ZK circuit
```shell
circom multiplier2.circom --r1cs --wasm --sym --c
```

- 3/ Move to the `./circuits/eoa_auth_js` directory
```shell
cd eoa_auth_js
```

- 4/ Computing the witness with WebAssembly
```shell
node generate_witness.js eoa_auth.wasm input.json witness.wtns
```

- 5-1/ Start a new "powers of tau" ceremony
```shell
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
```

- 5-2/ Contribute to the ceremony
```shell
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
```

- 6-1/ Start the generation of this phase 2:
```shell
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
```

- 6-2/ Generate a `.zkey` file that will contain the proving and verification keys (in phase 2)
```shell
snarkjs groth16 setup eoa_auth.r1cs pot12_final.ptau eoa_auth_0000.zkey
```

- 6-3/ Contribute to the phase 2 of the ceremony
```shell
snarkjs zkey contribute multiplier2_0000.zkey eoa_auth_0001.zkey --name="1st Contributor Name" -v
```

- 6-4/ Export the verification key:
```shell
snarkjs zkey export verificationkey eoa_auth_0001.zkey verification_key.json
```

- 7/ Generate a zk-Proof ([Groth16](https://eprint.iacr.org/2016/260) Proof) 
   - outputs 2 files are also generated at this point:
      - `proof.json`: it contains the proof.
      - `public.json`: it contains the values of the public inputs and outputs.
```shell
snarkjs groth16 prove eoa_auth_0001.zkey witness.wtns proof.json public.json
```

- 8/ Verifying a Proof
   - 3 files (`verification_key.json` and `proof.json` and `public.json`) would be used to check - if the proof is valid. 
   - If the proof is valid, the command outputs an `OK` in terminal.
```shell
snarkjs groth16 verify verification_key.json public.json proof.json
```

- 9/ Generate a Solidity Verifier contract
```shell
snarkjs zkey export solidityverifier eoa_auth_0001.zkey verifier.sol
```

<br>

### Run the test of ZK circuit (using `circom_tester`)
- Run test (using `circom_tester`)
```shell
/// NOTE: The directory is ./circuits

yarn test
```


<br>


### Smart contract (written in Solidity)

- Compile SC (Main file: `EoaAuth.sol`)
```shell
forge build
```

<br>

### Run the test of Smart contract
- 2/ Run Test (File: `EoaAuth.t.sol`)
```shell
forge test -vvv
```


<br>

## References

- Document of `Circom` and `Snarkjs`：https://docs.circom.io/getting-started/writing-circuits/
- **Email Recovery** module：https://github.com/zkemail/email-recovery
- **Email-auth SDK** (email-tx-builder)：https://github.com/zkemail/email-tx-builder
