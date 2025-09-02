// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Whitelist is EIP712, AccessControl {
    using ECDSA for bytes32;

    bytes32 private constant WHITELIST_TYPEHASH =
        keccak256("whitelist(address user, uint deadline)");
    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");

    mapping(bytes32 => bool) public usedSigns;
    mapping(address => bool) public whiteList;

    constructor() EIP712("Signed", "1") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(WHITELISTER_ROLE, msg.sender);
    }

    function grantWhitelister(
        address account
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(WHITELISTER_ROLE, account);
    }

    function joinWhiteListWithSignature(
        address user,
        uint256 deadline,
        bytes memory signature
    ) external {
        require(user == msg.sender);
        require(block.timestamp <= deadline);

        bytes32 sighash = keccak256(signature);
        require(!usedSigns[sighash], "sign already used");
        usedSigns[sighash] = true;

        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(WHITELIST_TYPEHASH, user, deadline))
        );

        address signAdd = digest.recover(signature);
        require(hasRole(WHITELISTER_ROLE, signAdd),"Invalid signer");
        whiteList[user] = true;


    }
}
