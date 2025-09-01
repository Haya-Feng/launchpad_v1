// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NToken.sol";

contract Launchpad is Ownable{

    NToken public token;
    uint256 public tokenPrice = 1e3;

    uint256 public saleEndTime;

    constructor(address _token) Ownable(_token) {
      token =  NToken(_token);
      saleEndTime = block.timestamp + 7 days;

    }

    function buy() external payable{
        require(block.timestamp <= saleEndTime, "sale end");
        uint256 num =  msg.value * tokenPrice;
        token.mint(msg.sender, num); 
    }

    function withdrawAll() external onlyOwner {
        require(block.timestamp > saleEndTime, "sale not end");  
        payable(msg.sender).transfer(address(this).balance);
    }

}
