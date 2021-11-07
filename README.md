![Star Left](./docs/star.svg)
<img src="./docs/star.svg">
![UniCode](./docs/unicode.svg)
<img src="./docs/unicode.svg">
![Star Right](./docs/star.svg)
<img src="./docs/star.svg">

# Crosschain Fast Transfers

## Web3 is full of barriers

Most people cannot experience the full power of Web3. They suffer under the tyranny of high gas fees and are locked out of experiencing apps that live on separate chains. These chains have implemented optimizations and features that allow certain dApps to exist that would never be feasible on Mainnet. And they go unused because crosschain barriers are sky high.

Crosschain payments should be easy. Let's make transfers become instant using loans. Let's rely on a pool of lenders that live on other blockchains. Those lenders can provide instant liquidity on new blockchains, in exchange for a bond issued by borrowers. These lenders will take any arbitrary action on behalf of the borrower. The only requirement is each participating chain to eventually synchronize their state.

*No matter which chain users prefer to store their money on, every smart contract on every blockchain will be available to them.*

## The Crosschain Loan Network

Here's how it works:
1. **The bond is issued.** The system starts with the borrower, who specifies an action they want done. The borrower generates a bond with a predetermined claim key that is rewarded to whoever fulfills the order. 
2. **The transaction is verified.** A lender sees this order and starts the verification process. Just like in real life, the lender must ensure that the transaction is valid and that the bond will eventually be accessible.
3. **The bond is claimed and the order is fulfilled.** After the lender is confident that they will be able to withdraw, they perform the action and receive a claim key, which is an NFT. 
4. **The bond is settled.** Once the bond and the claim key have arrived in the same blockchain, they can be combined. This triggers a withdrawal to the claimants account.

This is the simple, general protocol. In this repository, I have also demonstrated how this can be pushed to the limit.

 ## The Implementation: Zero-Knowledge Bonds

We want our transactions to be publicly verifiable, but there are many reasons to hide their content. For example, traders who must publicly declare their trades are vulnerable to front-running and other price manipulations. 

Zero-knowledge proofs allow us to prove things without knowing what they are. This repository uses the [AZTEC Protocol](https://aztec.network/). With AZTEC, the bonds that are created can keep their balance hidden while ensuring transactions are valid. Not even the contracts that facilitates this will know how much money is going where - only that the sheets are balanced. At the same time, borrowers can dole "viewing keys" to lenders which grant them special access to see the contents of the account. Lenders can make strong verifications. And when it comes time to move data across blockchain boundaries, zero-knowledge proofs allow us to roll up transactions. This means users of the network can pay a fraction of the gas fees as a direct, public transaction.

----------------------------------------------------------------------------------------

This repo is a submission the Uniswaps UniCode 2021 Hackathon.

`contracts/` contains the bond contracts.

`test/` demonstrates their usage.