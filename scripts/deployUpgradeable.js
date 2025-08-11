const { ethers, upgrades } = require("hardhat");

async function main() {
    const Token = await ethers.getContractFactory("NToken");
    const token = await Token.deploy();
    const tokenAdd = await token.getAddress();
    console.log("token contract address:", tokenAdd);

    const LaunchpadV1 = await ethers.getContractFactory("LaunchpadV1");
    const launchpadv1 = await upgrades.deployProxy(LaunchpadV1, [tokenAdd, ethers.parseEther("0.001"), 7 * 24 * 60 * 60], { initializer: "initialize", kind: "uups" });

    const launchpadv1Add = await launchpadv1.getAddress();
    console.log("launchpadv1 contract address:", launchpadv1Add);




    const LaunchpadV2 = await ethers.getContractFactory("LaunchpadV2");

    const v2 = await upgrades.upgradeProxy(launchpadv1Add, LaunchpadV2);
    const v2Add = await v2.getAddress();
    console.log("Launchpad upgraded to V2 at:", v2Add);

    await v2.initializeV2();
    console.log("V2 initialized");

    // set white
    await v2.toggleWhite();
    console.log("V2 white enabled");

    //set max 

    await v2.setMaxWallet(ethers.parseEther("1000"));
    console.log("V2 perMax 1000 ether");







}


main().catch((error) => {
    console.log(error);
    process.exitCode = 1;
})