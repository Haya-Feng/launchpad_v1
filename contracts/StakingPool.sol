// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StakingPool is ReentrancyGuard{

    IERC20 public stakingToken;
    IERC20 public earnedToken;

    uint256 public rewardRate = 10;
    uint256 public totalStaked;
    mapping (address=>uint256) public timeMap;
    mapping (address=>uint256) public stakedBalance;

     constructor (IERC20 _stakingToken,IERC20 _earnedToken){
        stakingToken = IERC20(_stakingToken);
        earnedToken = IERC20(_earnedToken);
        // 自我授权
        stakingToken.approve(address(this), type(uint256).max);
        earnedToken.approve(address(this), type(uint256).max);


    }

    // 计算奖励
    function earned(address account) internal view returns (uint256) {
     uint256 duration =   block.timestamp - timeMap[account];
     return (stakedBalance[account] * rewardRate * duration )/ (365 days  * 100);
        
    }

   

    // 质押代币
    function stak(uint256 amount) external nonReentrant{
        updTime(msg.sender);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        totalStaked+= amount;
    }


    // 提取本金+奖励

    function withdrawAll() external nonReentrant{
      stakingToken.transferFrom(address(this),msg.sender, stakedBalance[msg.sender]);
      uint256 reward = earned(msg.sender);
      earnedToken.transferFrom(address(this), msg.sender, reward);

      totalStaked-= stakedBalance[msg.sender];
      stakedBalance[msg.sender] = 0;

        
    }


     // 更新奖励
     function updTime(address account) internal {
        timeMap[account] = block.timestamp;
     }

}