
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface ICounter {
    function mint(address, uint256) external;
}

contract NavReward is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    bytes32 private immutable jobId;
    uint256 private constant fee = (1 * LINK_DIVISIBILITY) / 10;
    address public contractAdd;
    uint public readNumToNavRate;
    
    mapping(bytes32 => address) private recipient;
    mapping(address => uint) public hasMintRedNum;

    event RequestReadNum(bytes32 indexed requestId, uint256 volume);

    constructor(address _coin, uint _readNumToNavRate) ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
    
        contractAdd = _coin;
        readNumToNavRate = _readNumToNavRate;
    }
    
    function mintNav(address _user) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        req.add("get", string(abi.encodePacked("http://43.154.22.73:8080/user/sumClickCount?userWalletAddress=", Strings.toHexString(_user))));
        req.add("path", "data");
        req.addInt("times", 1);

        bytes32 _requestIds = sendChainlinkRequest(req, fee);
        recipient[_requestIds] = _user;
        return _requestIds;
    }

    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
        emit RequestReadNum(_requestId, _volume);

        require(_volume >= 0, "readNum not >= 0");
        require(_volume >= hasMintRedNum[recipient[_requestId]], "readNum error");
        
        uint availableMintReadNum = _volume - hasMintRedNum[recipient[_requestId]];
        uint mintCoinNum = availableMintReadNum / readNumToNavRate;
        require(availableMintReadNum >= readNumToNavRate, "availableMintReadNum not >= readNumToNavRate");
        hasMintRedNum[recipient[_requestId]] += mintCoinNum * readNumToNavRate;

        ICounter(contractAdd).mint(recipient[_requestId], mintCoinNum);
    }
}

