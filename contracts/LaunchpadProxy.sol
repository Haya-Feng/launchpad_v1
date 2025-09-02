// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LaunchpadStorage.sol";

contract LaunchpadProxy is LaunchpadStorage{
    constructor(address _logic,address _admin,address _staking){

        implementation = _logic;
        admin = _admin;

       (bool success,)=  _logic.delegatecall(
            abi.encodeWithSignature("initialize(address,address)", _staking,_admin)
        );
        require(success, "Initialization failed");

    }


    function upgradeto(address _implementation) external {
        require(msg.sender == admin,"only admin");
        implementation = _implementation;


        
    }

    fallback() external payable {
        address _impl = implementation;
        require(_impl != address(0));
        
        assembly {
            // 复制calldata到内存0x0位置
            calldatacopy(0, 0, calldatasize())
            
            // 执行函数调用
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            
            // 复制返回数据
            returndatacopy(0, 0, returndatasize())
            
            // 处理返回结果
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}