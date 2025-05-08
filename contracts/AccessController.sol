// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AccessController {
    address public admin;
    mapping(address => bool) public rewardManagers;

    event AdminTransferred(address indexed oldAdmin, address indexed newAdmin);
    event RewardManagerSet(address indexed account, bool enabled);

    modifier onlyAdmin() {
        require(msg.sender == admin, "AccessController: Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "AccessController: zero address");
        emit AdminTransferred(admin, newAdmin);
        admin = newAdmin;
    }

    function setRewardManager(address account, bool enabled) external onlyAdmin {
        rewardManagers[account] = enabled;
        emit RewardManagerSet(account, enabled);
    }

    function isRewardManager(address account) external view returns (bool) {
        return rewardManagers[account];
    }
}
