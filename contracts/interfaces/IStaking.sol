// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStaking {
    function getPoints(address user) external returns (uint256);

    function getUsdtAdd() external view returns(address) 
}
