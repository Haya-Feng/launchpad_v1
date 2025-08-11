// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LaunchpadV1.sol";

contract LaunchpadV2 is LaunchpadV1 {
    //增加白名单
    mapping(address => bool) public whiteList;
    bool public whiteListEnable;

    //增加最大购买量限制
    uint256 public maxPerWallet;

    // 添加初始部署初始化函数
    function initialize() public initializer {
        // 调用父合约的初始化函数
        __LaunchpadV1_init();
    }
    // 升级初始化函数
    function initializeV2() public reinitializer(2) {
        require(msg.sender == owner(), "Only owner can initialize!!!");
    }

    function setPerWhite(address user, bool status) external onlyOwner {
        whiteList[user] = status;
    }

    function toggleWhite() external onlyOwner {
        whiteListEnable = !whiteListEnable;
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        maxPerWallet = amount;
    }

    function buy() external payable override {
        require(block.timestamp < saleEnd, "sale End!!");
        if (whiteListEnable) {
            require(whiteList[msg.sender], "Not whitelisted");
        }

        uint256 amount = msg.value / tokenPrice;

        require(
            purchases[msg.sender] + amount <= maxPerWallet,
            "Exceeds wallet limit"
        );

        token.mint(msg.sender, amount);
        purchases[msg.sender] += amount;
        totalSold += amount;
    }
}
