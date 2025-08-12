const { ethers } = require("hardhat");

async function main() {

    const [owner, user1] = await ethers.getSigners();
    const user1Add = await user1.getAddress();

    //
    const Token = await ethers.getContractFactory("NToken");
    const token = await Token.deploy();
    const tokenAdd = await token.getAddress();
    console.log("token contract address:", tokenAdd);

    //
    const StakingFactory = await ethers.getContractFactory("StakingFactory");
    const stakingFactory = await StakingFactory.deploy();
    const stakingFactoryAdd = await stakingFactory.getAddress();
    console.log("StakingFactory contract address:", stakingFactoryAdd);

    // 创建事件监听器
    console.log("Setting up event listener...");
    const eventPromise = new Promise((resolve, reject) => {
        stakingFactory.on("PoolCreated", (owner, pool, event) => {
            console.log("Event received:", event);
            resolve(event);
        });

        // 设置超时以防事件丢失
        setTimeout(() => reject(new Error("Event not received within 30 seconds")), 30000);
    });

    const tx = await stakingFactory.createPool(
        tokenAdd,
        tokenAdd,
        10
    );
    const receipt = await tx.wait();
    console.log("Transaction receipt ", receipt);
    console.log("Transaction receipt status:", receipt.status === 1 ? "Success" : "Failed");


    console.log("Waiting for PoolCreated event...");
    const event = await eventPromise;

    const poolAdd = event.args.pool;
    const ownerAdd = event.args.owner;
    console.log("Staking pool address:", poolAdd);
    console.log("Staking owner address:", ownerAdd);


    //mint
    await token.mint(user1Add, ethers.parseEther("10"));

    //
    const stakingPool = await ethers.getContractAt("contracts/factory/StakingPool.sol:StakingPool", poolAdd);

    await token.connect(user1).approve(poolAdd, ethers.parseEther("100"));

    await stakingPool.connect(user1).stak(ethers.parseEther("10"));

    console.log("User staked 10 tokens");

    await ethers.provider.send("evm_increaseTime", [86400]);
    await ethers.provider.send("evm_mine");

    const earned = await stakingPool.connect(user1).earned(user1Add);
    console.log("User earned tokens:", ethers.formatEther(earned));

}



main().catch((error) => {
    console.log(error);
    process.exitCode = 1;
})