const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("staking contract test", function () {

    let Staking;
    let staking;
    let usdtAdd;





    beforeEach(async function () {
        Staking = await ethers.getContractFactory("Staking");
        staking = await Staking.deploy();
        //    const [owner, user1] = await ethers.getSigners();
    })

    it("should init mutil chain usdt address", async function () {
        usdtAdd = await staking.getUsdtAdd()
        expect(usdtAdd).to.equal("0x5FbDB2315678afecb367f032d93F642f64180aa3");
        expect(usdtAdd).to.be.properAddress;
    })
})