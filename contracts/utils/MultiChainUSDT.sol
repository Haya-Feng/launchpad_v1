// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library MultiChainUSDT {
    struct ChainConfig {
        uint256 chainId;
        address usdtAdd;
        string name;
    }


    function init(ChainConfig[] storage chains) internal {
        // 以太坊主网
        chains.push(ChainConfig(1, 0xdAC17F958D2ee523a2206206994597C13D831ec7, "Ethereum"));
        // BSC 主网
        chains.push(ChainConfig(56, 0x55d398326f99059fF775485246999027B3197955, "BSC"));
        // Polygon 主网
        chains.push(ChainConfig(137, 0xc2132D05D31c914a87C6611C10748AEb04B58e8F, "Polygon"));
    }

    function addChain(
        ChainConfig[] storage chains,
        uint256 _chainId,
        address _usdtAdd,
        string memory _name
    ) internal {
        chains.push(ChainConfig(_chainId, _usdtAdd, _name));
    }


    function getCurrentUSDTChain(ChainConfig[] storage chains) internal view returns(address) {
        for (uint256 index = 0; index < chains.length; index++) {
            if(chains[index].chainId == block.chainid){
                return chains[index].usdtAdd;
            }
            revert("Invaild chainId");
        }
        
    }
}
