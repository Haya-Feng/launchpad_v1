// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./utils/MultiChainUSDT.sol";

contract Staking is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using MultiChainUSDT for MultiChainUSDT.ChainConfig[];

    MultiChainUSDT.ChainConfig[] private supportedChains;

    uint256 public pointsPerSecond = 1e16; //每秒质押奖励0.01

    IERC20 public SToken;

    struct StakerInfo {
        uint256 stakedAmount;
        uint256 points;
        uint256 updTime;
    }
    address public immutable usdtAdd;

    mapping(address => StakerInfo) public users;

    event Staking(address sender, uint256 amount);
    event Unstaking(address sender, uint256 amount);

    constructor() Ownable(msg.sender) {
        MultiChainUSDT.init(supportedChains);
        usdtAdd = MultiChainUSDT.getCurrentUSDTChain(supportedChains);
        SToken = IERC20(usdtAdd);
    }

    //质押
    function staking(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        StakerInfo storage user = users[msg.sender];
        _updUserPoints(msg.sender);

        user.stakedAmount += amount;
        user.updTime += block.timestamp;

        SToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Staking(msg.sender, amount);
    }

    //解除质押
    function unstaking(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        StakerInfo storage user = users[msg.sender];
        require(amount <= user.stakedAmount, "Invalid amount");
        _updUserPoints(msg.sender);
        user.stakedAmount += amount;
        user.updTime += block.timestamp;
        SToken.safeTransferFrom(address(this), msg.sender, amount);
        emit Unstaking(msg.sender, amount);
    }

    //更新积分
    function _updUserPoints(address user) internal {
        StakerInfo storage user = users[msg.sender];
        if (user.stakedAmount > 0) {
            uint256 addP = (user.stakedAmount *
                (block.timestamp - user.updTime) *
                pointsPerSecond) / 1e18;
            user.points += addP;
        }
        user.updTime = block.timestamp;
    }

    function getPoints(address user) external returns (uint256) {
        _updUserPoints(user);
        StakerInfo storage user = users[msg.sender];
        return user.points;
    }

    function updPointsRate(uint256 _rate) external onlyOwner {
        pointsPerSecond = _rate;
    }

    function getUsdtAdd() external view returns (address) {
        return usdtAdd;
    }
}
