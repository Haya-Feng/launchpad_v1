// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LaunchpadStorage {

    struct Pool {
        address  proTokenAdd;
        address depositToken;
        uint256  raisingAmount;
        uint256  offerTokenAmount;
        uint256  startTime;
        uint256  endTime;
        bool  isInit;
        bool  isCancel;
    }
    address public implementation;
    address public admin;

    address public stakingAdd;
    Pool[] public pools;
    mapping(uint256 => mapping(address => uint256)) public userDepositAmounts;
    mapping(uint256 => uint256) public poolDepositAmounts;

    bool public isPaused;


}