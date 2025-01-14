# Ether EOA-auth SDK (EOA TX Buider)

## Technical Stack:
- The **Ether EOA-auth SDK (EOA TX Buider)** would be implemented with the following technical stack:
  - **ZK circuit**: written in **`Circom`** and **`Snarkjs`** .
  - **Smart contract**: written in Solidity.

<br>

## Overview

- The **Ether EOA-auth SDK (EOA TX Buider)** would be used for **account recovery** as a secondary account recovery module in the [**ZK Email Recovery**](https://github.com/zkemail/email-recovery). (NOTE：At the moment, the [**Ether Email-auth SDK (Email TX Builder)**](https://github.com/zkemail/email-tx-builder) has been used as a primary account recovery module for the [**ZK Email Recovery**](https://github.com/zkemail/email-recovery). Basically, the **Ether EOA-auth SDK (EOA TX Buider)** would be assumed that it work with the [**Ether Email-auth SDK (Email TX Builder)**](https://github.com/zkemail/email-tx-builder) in the [**ZK Email Recovery**](https://github.com/zkemail/email-recovery))

- The **EOA TX Builder** would be the module:
  - which can generate a proof to prove that a given `account` address is associated with a `guardian` address. (NOTE：This proof is called a `EOA proof` in this repo)
  - which can generate the Verifier contract that can verify the proof.

- The **EOA TX Builder** would basically be used with the **Email TX Builder** in the **Email-Recovery** module:
     https://github.com/masaun/email-recovery/blob/masaun_%2366_prototype-new-ERC7579-recovery-module/doc/summary-and-approach.md


<br>

## Installation

### ZK circuit (written in `Circom` and `Snarkjs`)

- Something
```shell

```

- Something
```shell

```

- Test
```shell

```


### Smart contract (written in Solidity)

- Something
```shell

```

- Something
```shell

```

- Test
```shell

```

<br>


## Integration with the `email-recovery` module

- Integration summary and approach:
   https://github.com/masaun/email-recovery/blob/masaun_%2366_prototype-new-ERC7579-recovery-module/doc/summary-and-approach.md
