// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title Bond
 * @author Quoc-Anh Vu
 * @dev An implementation of zero-knowledge conditional bonds. See "./Bond.sol" for info
 * about generic conditional bonds.
 *
 * The generic version has been modified so that no one but the borrow and lender can know
 * the balance and the order. This is useful to protect the borrower. For example, if the
 * borrower would like to make a trade through a decentralized exchange, a public declaration
 * bond would make the borrower vulnerable to front-running. In contrast, a zero-knowledge bond
 * would shield the borrower's privacy with math.
 */

import "./lib/Order.sol";
import "./lib/Principal.sol";
import "./BondClaim.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Bond {
    address claims;

    mapping(bytes32 => bool) exists;
    mapping(bytes32 => bool) settled;

    constructor(address _claims) {
        claims = _claims;
    }

    event Issued(bytes32 principalProofHash, bytes32 orderHash);
    event Settled(bytes32 orderHash);

    /**
     * @dev Borrowers issue debt by depositing tokens and defining claim conditions.
     *
     * @param _principalProofHash - A hash that can be used by the lender to verify that
     * funds have been deposited into a bond account. The account is held by the claim's
     * token ID (which is the orderHash).
     * @param _orderHash - The Order struct (which was defined in the origin Bond.sol),
     * except hashed by the borrower beforehand using keccak256. The order information
     * must be given to the lender secretly.
     */
    function issue(bytes32 _principalProofHash, bytes32 _orderHash)
        external
        payable
    {
        require(
            !exists[_orderHash],
            "An order with the same claim key (orderHash) already exists."
        );

        // 1) Deposit tokens into bond from borrower's account.
        // TODO: Interact with ACE

        if (success) {
            // 2) Store the bond in storage.
            exists[_orderHash] = true;
            emit Issued(_principalProofHash, _orderHash);
        }
    }

    /**
     * @dev Claimants settle debt by proving claim ownership and withdrawing tokens.
     *
     * Claim ownership is proven if the msg.sender == ownerOf(claimToken).
     * Since claims are implemented as NFTs, they may be traded and the claim owner may
     * not be the original lender who fulfilled the order.
     *
     * @param _orderHash - A keccack256 hash of the original order struct which is also the
     *                     tokenId of the claim NFT.
     */
    function settle(bytes32 _orderHash) external {
        require(
            !isSettled(_orderHash),
            "The bond has already been settled and the account has been withdrawn from."
        );

        // 1) Verify claimant rights.
        if (
            BondClaim(claims).isClaimed(_orderHash) &&
            msg.sender == BondClaim(claims).ownerOf(uint256(_orderHash))
        ) {
            // 2) Withdraw token to claimant.
            // TODO: Interact with ACE.

            if (success) {
                // 3) Mark settlement of a bond.
                settled[_orderHash] = true;
                emit Settled(_orderHash);
            }
        }
    }

    /**
     * @dev Returns whether the bond has already been settled and the account has
     * been withdrawn from.
     *
     * @param _orderHash - A keccack256 hash of the original order struct.
     */
    function isSettled(bytes32 _orderHash) public view returns (bool ret) {
        return settled[_orderHash];
    }
}
