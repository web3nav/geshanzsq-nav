// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";
/**
 * @title 质押合约
 */
contract Staker {

    // 用户质押金额
    mapping(address => uint) public balances;

    // 用户质押是否完成状态
    mapping(address => bool) public stackStatus;

    mapping(address => bool) public blackList;

    // 质押完成门槛
    uint public constant threshold = 1 gwei;

    uint public totalStackAmt;

    address public immutable admin;

    event Stake(address indexed sender, uint amount);
    event Withdraw(address indexed sender, uint amount);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "not authorized!");
        _;
    }

    /**
     * 用户不能再黑名单中
     */
    modifier notBlackListUser {
        require(!blackList[msg.sender], "user is in blackList");
        _;
    }

    /**
     * 不能重复质押   
     */
    modifier notRepeateStack {
        require(!stackStatus[msg.sender], "user already stack");
        _;
    }

    /**
     * 质押
     */
    function stake() external payable notRepeateStack notBlackListUser {
        uint amount = msg.value;
        require(amount == threshold, "stack amt error");
        
        // update the user's balance
        balances[msg.sender] += amount;
        stackStatus[msg.sender] = true;
        totalStackAmt += amount;

        emit Stake(msg.sender, amount);
    }

    /**
     * 提现
     */
    function withdraw() external {
        uint256 userBalance = balances[msg.sender];

        // 检查用户是否有余额可以提现
        require(userBalance > 0, "You don't have balance to withdraw");

        // 重置用户余额和质押状态
        balances[msg.sender] = 0;
        stackStatus[msg.sender] = false;
        totalStackAmt -= userBalance;

        // 将余额转回给用户
        (bool sent, ) = msg.sender.call{value: userBalance}("");
        require(sent, "Failed to send user balance back to the user");

        emit Withdraw(msg.sender, userBalance);
    }

    function addBlackList(address _user) external onlyAdmin {
        blackList[_user] = true;
    }

    function removeBlackList(address _user) external onlyAdmin {
        blackList[_user] = false;
    }

    function getUserStackAmt() external view returns (uint) {
        return balances[msg.sender];
    }

    function getUserStackStatus() external view returns (bool) {
        return stackStatus[msg.sender];
    }

}
