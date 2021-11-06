// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title BondClaim
 * @author Quoc-Anh Vu
 * @dev An interface defining the claim (key) of a conditional bond.
 *
 * Claims are the keys that unlock bonds. Once they are earned, they can be
 * bought and sold since they implement the NFT interface. As a NFT, the tokenId
 * corresponding to the bond is the SHA3 hash of the order struct: keccak256(order).
 *
 * Note that a claim can be made of any bond, no matter how spurious. It is the
 * responsibility of the lender to ensure that the bond exists and will eventually be settled.
 * For example, if a bond is used to hasten a transfer of tokens between two networks
 * (like L2 Optimism -> L1 Mainnet), then the lender must ensure that the bond has been
 * committed, that a dispute cannot void the bond, and that the bond has not already been
 * fulfilled by another lender.
 */

import "./lib/Order.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BondClaim is ERC721 {
    mapping(bytes32 => bool) claimed;

    constructor() ERC721("Bond", "BOND") {}

    event Claimed(bytes32 orderHash);

    /**
     * @dev Lenders claim ownership of a bond by fulfilling the order.
     *
     * An order is fulfilled if a function is run with the parameters defined by the borrower.
     * This parameters of this function need to include all the data necessary for
     * this contract to make a delegatecall and fulfill the order.
     *
     * Note that in this implementation, an order only supports an ERC20 transfer.
     * In future versions, the order struct should include a call signature and call
     * parameter data.
     *
     * @param _order - A struct with all the information needed for this contract to
     *                 forward the call to another function.
     */
    function claim(Order calldata _order) external {
        bytes32 orderHash = keccak256(abi.encode(_order));
        require(
            !isClaimed(orderHash),
            "The bond has already been claimed and the order has been fulfilled."
        );

        // 1) The lender fulfills the order.
        bool success = IERC20(_order.token).transferFrom(
            msg.sender,
            _order.to,
            _order.value
        );
        //

        // 2) The lender is awarded the claim.
        if (success) {
            claimed[orderHash] = true;
            _mint(msg.sender, uint256(orderHash));
            emit Claimed(orderHash);
        }
    }

    /**
     * @dev Returns whether the bond has been claimed and the order has been fulfilled.
     *
     * @param _orderHash - A keccack256 hash of the original order struct.
     */
    function isClaimed(bytes32 _orderHash) public view returns (bool ret) {
        return claimed[_orderHash];
    }
}
