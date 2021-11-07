# Bond Contracts

This is the conditional bond protocol specification. More information is inside the code comments.

- `Bond.sol` defines a generic bond contract where borrowers can issue loans that can only be claimed once an order is fulfilled.
- `BondClaim.sol` defines a generic bond claim contract where lenders can fulfill orders and claim keys that unlock the bond's principal on maturity.
- `ZkBond.sol` extends bond contract with zero-knowledge proofs. Here, only the borrower and the lender can know the principal and the order.