# Staking Pool & Launchpad Simple Project

[![Solidity Version](https://img.shields.io/badge/Solidity-^0.8.20-blue)](https://soliditylang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个超简易的质押池和代币发行平台项目，包含 ERC20 代币、质押合约和代币发行平台，专供学习,也会陆续优化更新。

## 功能

- 🪙 创建和管理 ERC20 代币
- 🔒 质押代币获取奖励
- 🚀 代币发行平台（Launchpad）
- 📊 完整的测试覆盖率

## 快速开始

### 安装依赖

npm install

### 部署到本地网络

npx hardhat node

npx hardhat compile

npx hardhat run scripts/deploy.js --network localhost


### 合约地址（示例）

| 合约 | 地址 |
|------|------|
| NToken | `0x5FbDB2315678afecb367f032d93F642f64180aa3` |
| StakingPool | `0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0` |
| Launchpad | `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512` |

### 合约交互示范

### 1.启动 Hardhat 控制台
npx hardhat console --network localhost

### 2.console语句



const token = await ethers.getContractAt("NToken", "代币合约地址")

const launchpad = await ethers.getContractAt("Launchpad", "Launchpad地址")

const staking = await ethers.getContractAt("StakingPool", "质押池地址") // 获取合约实例




const [owner, user1] = await ethers.getSigners() // 获取测试账户



const stakAddress = await staking.getAddress() // 获取质押池地址



await launchpad.connect(user1).buy({value: ethers.parseEther("10")}) //用户1买代币



await token.balanceOf(user1.address) //用户查代币余额



await token.connect(user1).approve(staking.address, ethers.utils.parseEther("100")) //用户授权



const stakingTAddress = await staking.stakingToken()

const stakingT = await ethers.getContractAt("IERC20", stakingTAddress)

const earnedTAddress = await staking.earnedToken()

const earnedT= await ethers.getContractAt("IERC20", earnedTAddress) //质押/奖励代币合约地址




await network.provider.send("evm_increaseTime", [24 * 3600]) 

await network.provider.send("evm_mine") // 模拟时间前进一天



await staking.connect(user1).withdrawAll() //提取本金和奖励




## 项目优化

1.使用UUPS代理模式实现合约的可升级功能，并设置白名单以及最大购买token量限制
  - 部署`LaunchpadV1`代理合约，并初始化，升级到`LaunchpadV2`
  - 部署脚本`deployUpgradeable.js`

2.使用工厂模式动态创建staking合约，以并统一管理
  - 引入OpenZeppelin的Clones合约，供了最小代理`（EIP-1167）`的实现
  - 调用createPool()创建新合约会返回一个交易对象（tx），需要获取合约address需要从`事件日志（event）`中提取

3.集成 OpenZeppelin 的 AccessControl，实现白名单签名验证（EIP-712）小工具 





## 许可证
MIT

