// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CommunityToken {
    string public name = "TokenHiveToken";
    string public symbol = "CTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public rewardManager;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event RewardManagerUpdated(address indexed newManager);

    modifier onlyRewardManager() {
        require(msg.sender == rewardManager, "Not reward manager");
        _;
    }

    function setRewardManager(address _manager) external {
        require(rewardManager == address(0), "Already set");
        rewardManager = _manager;
        emit RewardManagerUpdated(_manager);
    }

    function mint(address to, uint256 amount) external onlyRewardManager {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}
