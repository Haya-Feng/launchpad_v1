// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NToken is ERC20,Ownable{
    // address public owner;

    constructor()ERC20("NToken","NTK")Ownable(msg.sender){
        // owner = msg.sender;
        _mint(owner(), 1_000_000*10**decimals());

    }
    function mint(address to,uint256 amount) public onlyOwner{
        // require(msg.sender==owner,"only launchpad");
        _mint(to, amount);
        
    }



}