// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./NToken.sol";

contract LaunchpadV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    NToken public token;
    uint256 public tokenPrice;
    mapping(address => uint256) public purchases;
    uint256 public saleEnd;
    uint256 public totalSold;

    // constructor() {
    //     _disableInitializers();
    // }

    function initialize(
        address _token,
        uint256 _tokenPrice,
        uint256 _duration
    ) external initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        token = NToken(_token);
        tokenPrice = _tokenPrice;
        saleEnd = block.timestamp + _duration;
    }

    function __LaunchpadV1_init() internal virtual onlyInitializing {
        // 调用父合约的初始化函数
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function buy() external payable virtual {
        require(block.timestamp < saleEnd, "sale End!!");
        uint256 amount = msg.value / tokenPrice;
        token.mint(msg.sender, amount);
        purchases[msg.sender] += amount;
        totalSold += amount;
    }

    function withdrawFunds() external onlyOwner {
        require(block.timestamp >= saleEnd, "sale not End!!");
        payable(owner()).transfer(address(this).balance);
    }
}
