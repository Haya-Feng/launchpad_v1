// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./StakingPool.sol";

contract StakingFactory is Ownable {
    address public immutable stakingImpl;

    using Clones for address;

    address[] public allPools;
    mapping(address => address[]) public poolsOfOwner;

    event PoolCreated(address indexed owner, address pool);

    constructor()Ownable(msg.sender) {
        stakingImpl = address(new StakingPool(address(this)));
    }

    function createPool(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate
    ) external returns (address) {
        address clone = stakingImpl.clone();

        StakingPool(clone).initialize(
            _stakingToken,
            _rewardToken,
            _rewardRate,
            msg.sender
        );
        allPools.push(clone);
        poolsOfOwner[msg.sender].push(clone);

        emit PoolCreated(msg.sender, clone);
        return clone;
    }

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }

    function getPoolsByOwner(
        address owner
    ) external view returns (address[] memory) {
        return poolsOfOwner[owner];
    }
}
