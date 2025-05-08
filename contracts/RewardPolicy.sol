// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract RewardPolicy {
    address public admin;

    enum ActivityType { Post, Comment, Vote }

    mapping(ActivityType => uint256) public rewardAmounts;

    event RewardAmountSet(ActivityType indexed activity, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "RewardPolicy: Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;

        // 초기 보상값 설정 (예시)
        rewardAmounts[ActivityType.Post] = 10 ether;
        rewardAmounts[ActivityType.Comment] = 5 ether;
        rewardAmounts[ActivityType.Vote] = 2 ether;
    }

    function setRewardAmount(ActivityType activity, uint256 amount) external onlyAdmin {
        rewardAmounts[activity] = amount;
        emit RewardAmountSet(activity, amount);
    }

    function getRewardAmount(ActivityType activity) external view returns (uint256) {
        return rewardAmounts[activity];
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "RewardPolicy: zero address");
        admin = newAdmin;
    }
}
