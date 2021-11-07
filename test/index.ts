import { Provider } from "@ethersproject/abstract-provider";
import { Signer } from "@ethersproject/abstract-signer";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ethers as eth } from "ethers";
import Web3 from "web3";
import { Bond, BondClaim, ERC20Mintable } from "../typechain";
import chalk from "chalk";

describe("Generic Bond", function () {
  let bonds: Bond;
  let claims: BondClaim;
  let tokens: ERC20Mintable;

  let alice;
  let bob;
  let charlie;

  beforeEach(async function () {
    // Deploy contracts.
    const Bond = await ethers.getContractFactory("Bond");
    const BondClaim = await ethers.getContractFactory("BondClaim");
    const Token = await ethers.getContractFactory("ERC20Mintable");

    claims = await BondClaim.deploy();
    bonds = await Bond.deploy(claims.address);
    tokens = await Token.deploy();

    [alice, bob, charlie] = await ethers.getSigners();

    await claims.deployed();
    await bonds.deployed();
    await tokens.deployed();

    // Log addresses and setup listeners to log events.
    let names = {};
    names[alice.address] = chalk.red("Alice");
    names[bob.address] = chalk.blue("Bob");
    names[charlie.address] = chalk.green("Charlie");
    names[bonds.address] = chalk.magenta("BondContract");

    console.log(names[alice.address] + "@" + alice.address);
    console.log(names[bob.address] + "@" + bob.address);
    console.log(names[charlie.address] + "@" + charlie.address);
    console.log(names[bonds.address] + "@" + bonds.address);

    tokens.on("Transfer", (_from, _to, _value) => {
      console.log(
        chalk.bold("Transfer(") +
          names[_from] +
          "@" +
          _from.substring(0, 8) +
          "..." +
          ", " +
          names[_to] +
          "@" +
          _to.substring(0, 8) +
          "..." +
          ", " +
          _value +
          chalk.bold(")")
      );
    });
    bonds.on("Issued", (_value, _token, _orderHash) => {
      console.log(
        chalk.bold("Issued(") +
          "value: " +
          _value +
          ", " +
          "token: @" +
          _token +
          ", " +
          "@" +
          _orderHash +
          chalk.bold(")")
      );
    });
    claims.on("Claimed", (_orderHash) => {
      console.log(chalk.bold("Claimed(@") + _orderHash + chalk.bold(")"));
    });
    bonds.on("Settled", (_orderHash) => {
      console.log(chalk.bold("Settled(@") + _orderHash + chalk.bold(")"));
    });
  });

  it("Should complete full transaction successfully", async function () {
    // 1) Mint tokens to Alice and Bob.
    await tokens.mint(alice.address, 1000);
    await tokens.mint(bob.address, 99);

    // 2) Alice creates a bond. Alice wants to send $99 to Charlie. Alice will pay $100.
    const principal: Principal = { value: 100, token: tokens.address };
    const order: Order = {
      to: charlie.address,
      value: 99,
      token: tokens.address, // ERC-20 token
      nonce: eth.utils.randomBytes(32), // This is a random hash supplied by the borrower
    };
    await tokens.connect(alice).approve(bonds.address, 100);
    await bonds.connect(alice).issue(principal, order);
    let issuedEvent = new Promise<eth.BytesLike>((resolve) => {
      bonds.on("Issued", (_value, _token, _orderHash) => {
        resolve(_orderHash);
      });
    });
    const orderHash = await issuedEvent;

    // 3) Bob creates a bond claim. Bob sends $99 to Charlie.
    await tokens.connect(bob).approve(claims.address, 99);
    await claims.connect(bob).claim(order);
    expect(await claims.ownerOf(orderHash)).to.equal(bob.address);

    // 4) Later, Bob settles the bond. Bob receives $100 from the bond.
    await bonds.connect(bob).settle(orderHash);
    expect(await bonds.isSettled(orderHash));
    await new Promise<void>((resolve) => {
      tokens.on("Transfer", (_from, _to, _value) => {
        if (_to == bob.address) {
          resolve();
        }
      });
    });

    // 5) Ensure that everybody gets what they expect.
    expect(await tokens.balanceOf(alice.address)).to.equal(900);
    expect(await tokens.balanceOf(bob.address)).to.equal(100);
    expect(await tokens.balanceOf(charlie.address)).to.equal(99);
  });
});

interface Principal {
  value: number;
  token: string;
}
interface Order {
  to: string;
  value: number;
  token: string; // ERC-20 token
  nonce: eth.Bytes; // This is a random hash supplied by the borrower
}
