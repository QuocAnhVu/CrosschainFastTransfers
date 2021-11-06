// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

struct Order {
    address to;
    uint256 value;
    address token; // ERC-20 token
    bytes32 nonce; // This is a random hash supplied by the borrower
}
