// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IStaking.sol";
import "./LaunchpadStorage.sol";

contract Launchpad is LaunchpadStorage, ReentrancyGuard {
    using SafeERC20 for IERC20;
    modifier notEmergencyPaused() {
        require(!isPaused, "Contract is emergency paused");
        _;
    }
    modifier isAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    event CreatePool(
        uint256 poolId,
        address proTokenAdd,
        uint256 raisingAmount
    );
    event UserDeposited(
        uint256 poolId,
        address sender,
        uint256 amount,
        address tokenAddress
    );
    event Subscription(
        uint256 poolId,
        address sender,
        uint256 userOfferingAmount,
        uint256 userRefundAmount
    );
    event Withdraw(
        uint256 poolId,
        address receiptAdd,
        uint256 currentAmount
    );
    event CancelPool(uint256 poolId, bool isCancel);
    event Paused(bool isPaused);

    function initialize(address _stakingAdd, address _admin) external {
        require(stakingAdd == address(0));
        stakingAdd = _stakingAdd;
        admin = _admin;
    }

    function createPool(
        address _proTokenAdd,
        address _depositToken,
        uint256 _raisingAmount,
        uint256 _offerTokenAmount,
        uint256 _startTime,
        uint256 _endTime
    ) external {
        require(_startTime < _endTime, "Invailed Time");
        pools.push(
            Pool({
                proTokenAdd: _proTokenAdd,
                depositToken: _depositToken == address(0)
                    ? address(0)
                    : IStaking(stakingAdd).getUsdtAdd(),
                raisingAmount: _raisingAmount,
                offerTokenAmount: _offerTokenAmount,
                startTime: _startTime,
                endTime: _endTime,
                isInit: true,
                isCancel: false
            })
        );

        emit CreatePool(pools.length - 1, _proTokenAdd, _raisingAmount);
    }

    function deposit(
        uint256 _poolId,
        uint256 _amount
    ) external payable nonReentrant notEmergencyPaused {
        Pool storage pool = pools[_poolId];
        require(
            block.timestamp >= pool.startTime &&
                block.timestamp <= pool.endTime,
            "Not active"
        );
        require(!pool.isCancel);
        require(pool.isInit);

        //
        uint256 userPoints = IStaking(stakingAdd).getPoints(msg.sender);
        require(userPoints >= 10e18, "userPoints is not enough");

        //
        if (pool.depositToken == address(0)) {
            require(msg.value == _amount);
        } else {
            require(msg.value == 0, "ETH not allowed");
            address usdtAdd = IStaking(stakingAdd).getUsdtAdd();
            // require(usdtAdd == _tokenAdd, "Invailed token");

            IERC20(usdtAdd).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        userDepositAmounts[_poolId][msg.sender] += _amount;
        poolDepositAmounts[_poolId] += _amount;

        emit UserDeposited(_poolId, msg.sender, _amount, pool.depositToken);
    }

    function subscription(
        uint256 _poolId
    ) external nonReentrant notEmergencyPaused {
        Pool storage pool = pools[_poolId];
        require(block.timestamp >= pool.endTime);
        require(!pool.isCancel);
        uint256 userAmount = userDepositAmounts[_poolId][msg.sender];
        require(userAmount > 0, "what are u doing now?");

        uint256 poolTotal = poolDepositAmounts[_poolId];

        uint256 userOfferingAmount = (userAmount * pool.offerTokenAmount) /
            poolTotal;
        uint256 userRefundAmount = 0;

        // 超额认购
        if (poolTotal > pool.raisingAmount) {
            userRefundAmount =
                userAmount -
                (userAmount * pool.raisingAmount) /
                poolTotal;
        }

        userDepositAmounts[_poolId][msg.sender] = 0;

        //
        IERC20(pool.proTokenAdd).transfer(msg.sender, userOfferingAmount);
        if (pool.depositToken == address(0)) {
            payable(msg.sender).transfer(userRefundAmount);
        } else {
            IERC20(pool.depositToken).transfer(msg.sender, userRefundAmount);
        }

        emit Subscription(
            _poolId,
            msg.sender,
            userOfferingAmount,
            userRefundAmount
        );
    }
    function withdraw(uint256 _poolId, address receiptAdd) external isAdmin {
        uint256 total = poolDepositAmounts[_poolId];
        Pool storage pool = pools[_poolId];

        require(block.timestamp > pool.endTime, "Not ended");
        require(!pool.isCancel, "Pool cancelled");
        require(total > 0, "no money");

        uint256 currentAmount = total > pool.raisingAmount
            ? pool.raisingAmount
            : total;

        pool.isCancel = true;
        total = 0;

        bool success;

        if (pool.depositToken == address(0)) {
            (success, ) = receiptAdd.call{value: currentAmount}("");
        } else {
            success = IERC20(pool.depositToken).transfer(
                receiptAdd,
                currentAmount
            );
        }
        require(success, "Withdraw failed");

        emit Withdraw(_poolId, receiptAdd, currentAmount);
    }

    function isCancelPool(uint256 _poolId, bool _isCancel) external isAdmin {
        Pool storage pool = pools[_poolId];
        pool.isCancel = _isCancel;

        emit CancelPool(_poolId, _isCancel);
    }

    function paused(bool pause) external isAdmin {
        isPaused = pause;
        emit Paused(isPaused);
    }

    // 接收ETH
    receive() external payable {}
}
