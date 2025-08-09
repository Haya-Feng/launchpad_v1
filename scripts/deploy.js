const hre = require("hardhat");
const fs = require('fs');

async function main() {

  const [deployer,user1] = await hre.ethers.getSigners();
  console.log("deploy address:", deployer.address);

  //deploy erc20
  const Token = await hre.ethers.getContractFactory("NToken");
  const token = await Token.deploy();
  console.log("token contract address:",await token.getAddress() );
  const tokenAddress = await token.getAddress();

  //deploy launchpad
  const Launchpad = await hre.ethers.getContractFactory("Launchpad");
  const launchpad = await Launchpad.deploy(tokenAddress);
  const launchpadAddress =  await launchpad.getAddress() 
  console.log("launchpad contract address:",launchpadAddress);



  //deploy staking
const Staking = await hre.ethers.getContractFactory("StakingPool");
  const staking = await Staking.deploy(tokenAddress,tokenAddress);
  const stakAddress = await staking.getAddress();
  console.log("staking contract address:",stakAddress );


  // init 
  try {
    console.log("stakingPool init 100000 token start...");
    const rewardAmount = hre.ethers.parseUnits("100000",18);
    await token.mint(stakAddress, rewardAmount);
    console.log("stakingPool init 100000 token succ");
    
  } catch (error) {
        console.log("stakingPool init 100000 token fail:",error);

  }

  //transferOwnership
  await token.transferOwnership(launchpadAddress);
  console.log("NToken change owner =======> Launchpad succ");


  // 保存到文件
  const data = {
    network: network.name,
    tokenContractAddress: tokenAddress,
    launchpadContractAddress: launchpadAddress,
    stakContractAddress: stakAddress,
    deployer: deployer.address,
    user1: user1.address,
    timestamp: new Date().toISOString()
  };

  fs.writeFileSync("deployment.json",JSON.stringify(data, null, 2));
  console.log("deployment save succ!!!!")
  
  



    
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });