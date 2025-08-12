// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract StakingPool is Ownable, Initializable{
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    
    uint256 public rewardRate;
    uint256 public totalStaked;
    
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastUpdateTime;
    
    constructor(address initialOwner) Ownable(initialOwner){
        // 禁用实现合约的构造函数
        _disableInitializers();
    }
    
    function initialize(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate,
        address owner
    ) external initializer {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
        _transferOwnership(owner);
    }
    
    function earned(address account) public view returns (uint256) {
        uint256 duration = block.timestamp - lastUpdateTime[account];
        return (stakedBalance[account] * rewardRate * duration) / (365 days * 100);
    }
    
    function stak(uint256 amount) external {
        updateReward(msg.sender);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;
    }
    
    function withdraw() external {
        updateReward(msg.sender);
        uint256 amount = stakedBalance[msg.sender];
        
        stakingToken.transfer(msg.sender, amount);
        rewardToken.transfer(msg.sender, earned(msg.sender));
        
        totalStaked -= amount;
        stakedBalance[msg.sender] = 0;
    }
    
    function updateReward(address account) internal {
        uint256 reward = earned(account);
        lastUpdateTime[account] = block.timestamp;
    }
}