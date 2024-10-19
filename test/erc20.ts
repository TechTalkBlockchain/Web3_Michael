import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("ERC20Token", function () {
  it("Should deploy and mint initial supply to deployer", async function () {
    const [deployer] = await ethers.getSigners();
    const ERC20Token = await ethers.getContractFactory("ERC20Token");
    const token = await ERC20Token.deploy("MyToken", "MTK", 1000000);
    await token.deployed();

    const balance = await token.balanceOf(deployer.address);
    expect(balance).to.equal(ethers.parseUnits("1000000", 18));
  });

  it("Should allow token transfers between accounts", async function () {
    const [deployer, addr1] = await ethers.getSigners();
    const ERC20Token = await ethers.getContractFactory("ERC20Token");
    const token = await ERC20Token.deploy("MyToken", "MTK", 1000000);
    await token.deployed();

    await token.transfer(addr1.address, ethers.parseUnits("500", 18));
    const addr1Balance = await token.balanceOf(addr1.address);
    expect(addr1Balance).to.equal(ethers.parseUnits("500", 18));
  });
});