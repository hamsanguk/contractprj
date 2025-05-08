// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAccessController {
    function isRewardManager(address user) external view returns (bool);
}

interface ICommunityToken {
    function mint(address to, uint256 amount) external;
}

interface IRewardPolicy {
    function getRewardAmount(uint8 activityType) external view returns (uint256);
}

contract RewardManager {
    IAccessController public accessController;
    ICommunityToken public token;
    IRewardPolicy public rewardPolicy;

    // 중복 보상 방지 기록
    mapping(address => mapping(uint8 => bool)) public hasClaimed;

    constructor(
        address _access,
        address _token,
        address _policy
    ) {
        accessController = IAccessController(_access);
        token = ICommunityToken(_token);
        rewardPolicy = IRewardPolicy(_policy);
    }

    modifier onlyAuthorized() {
        require(accessController.isRewardManager(msg.sender), "Not authorized");
        _;
    }

    function reward(address user, uint8 activityType) external onlyAuthorized {
        require(!hasClaimed[user][activityType], "Already claimed");

        uint256 amount = rewardPolicy.getRewardAmount(activityType);
        token.mint(user, amount);

        hasClaimed[user][activityType] = true;
    }
}
