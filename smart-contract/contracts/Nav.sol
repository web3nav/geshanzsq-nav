// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Nav is ERC20, AccessControl, Ownable {
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("nav", "NAV") {
        // _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount * (10 ** ERC20.decimals()));
    }

    function grantRole(address _user) public onlyOwner {
        _grantRole(MINTER_ROLE, _user);
    }

}