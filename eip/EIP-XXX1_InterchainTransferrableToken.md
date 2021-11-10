# Dependencies
Builds on ERC20.
Builds on EIP-XXX0.

# Additions to ERC20

- "Canon" and "noncanon" are defined by the token.
 
All ERC20 contracts must have a new method: canonicalChainID().
All ERC20 contracts should return the same canonical chain id across all chains.
Canonical ownership is determined by ownership on the canonical chain.
ERC20 contracts on noncanonical chains may not mint uncollateralized tokens.

# Transfers

- A chain has a "Holding Account" on the canonical chain which is defined as a contract address to which tokens are credited while they are transferred to another chain.

- The funds in the Holding Account are referred to as "Collateral". The only acceptable form of Collateral are the same type and amount of ERC20 coins that are transferred.

## Canon A -> Noncanon B

This is called a "Deposit".

1. Collateral is withdrawn from a Holding Account, owned by the noncanonical chain B, that exists on canonical chain A.

At this point, the spec does not enforce any other rules. In practice, the chain B would mint new tokens and dole them to the respective contracts based on who or what initiated the Deposit.

## Given Canon A, Noncanon B -> Noncanon C

This is called a "Transfer".

1. Collateral is withdrawn from a Holding Account, owned by the noncanonical chain B, that exists on canonical chain A.
2. Collateral is deposited to a Holding Account, owned by the noncanonical chain C, that exists on canonical chain A.

Again, the spec does not enforce any other rules. In practice, chain B and C are in charge of coordinating their respective ledgers to reflect the transfer in the canonical chain.

## Noncanon B -> Canon A

This is called a "Withdrawal".

1. Collateral is withdrawn from a Holding Account, owned by the noncanonical chain B, that exists on canonical chain A.

The spec does not enforce any other rules. Chain B is responsible for correctly burning the tokens on their own chain.