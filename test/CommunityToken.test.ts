import { ethers } from "hardhat";
import { expect } from "chai";

describe("communityToken System", function () {
  let accessController: any;
  let communityToken: any;
  let communityTokenProxy: any;
  let rewardManager: any;
  let rewardManagerProxy: any;
  let rewardPolicy: any;
  let deployer: any;

  beforeEach(async function () {
    [deployer] = await ethers.getSigners();

    // Deploy AccessController
    const AccessController = await ethers.getContractFactory("AccessController");
    accessController = await AccessController.deploy();
    await accessController.deployed();

    // Deploy RewardPolicy
    const RewardPolicy = await ethers.getContractFactory("RewardPolicy");
    rewardPolicy = await RewardPolicy.deploy();
    await rewardPolicy.deployed();

    // Deploy CommunityToken
    const CommunityToken = await ethers.getContractFactory("CommunityToken");
    communityToken = await CommunityToken.deploy();
    await communityToken.deployed();

    // Set RewardManager in CommunityToken
    await communityToken.setRewardManager(deployer.address);

    // Deploy RewardManager
    const RewardManager = await ethers.getContractFactory("RewardManager");
    rewardManager = await RewardManager.deploy(accessController.address, communityToken.address, rewardPolicy.address);
    await rewardManager.deployed();

    // Set the RewardManager in AccessController
    await accessController.setRewardManager(rewardManager.address, true);

    // Deploy Proxy for CommunityToken
    const CommunityTokenProxy = await ethers.getContractFactory("CommunityTokenProxy");
    communityTokenProxy = await CommunityTokenProxy.deploy(communityToken.address);
    await communityTokenProxy.deployed();

    // Deploy Proxy for RewardManager
    const RewardManagerProxy = await ethers.getContractFactory("RewardManagerProxy");
    rewardManagerProxy = await RewardManagerProxy.deploy(rewardManager.address);
    await rewardManagerProxy.deployed();
  });

  it("should allow admin to set and update Reward Manager", async function () {
    // Check if the RewardManager is correctly set
    expect(await accessController.isRewardManager(rewardManager.address)).to.be.true;

    // Change Reward Manager to a new address
    const [newRewardManager] = await ethers.getSigners();
    await accessController.setRewardManager(newRewardManager.address, true);

    // Ensure the new Reward Manager is set
    expect(await accessController.isRewardManager(newRewardManager.address)).to.be.true;
  });

  it("should allow RewardManager to mint tokens", async function () {
    // Mint tokens for a user
    const [user] = await ethers.getSigners();
    await rewardManager.reward(user.address, 0); // ActivityType.Post = 0

    // Check balance after minting
    const balance = await communityToken.balanceOf(user.address);
    expect(balance).to.equal(10e18); // 10 ether for Post activity
  });

  it("should not allow unauthorized users to mint tokens", async function () {
    // Try minting from an unauthorized user
    const [user] = await ethers.getSigners();
    await expect(
      rewardManager.reward(user.address, 0) // ActivityType.Post = 0
    ).to.be.revertedWith("Not authorized");
  });

  it("should allow RewardPolicy admin to set new reward amount", async function () {
    // Set a new reward for "Post"
    await rewardPolicy.setRewardAmount(0, 20e18); // ActivityType.Post = 0

    // Fetch new reward amount for "Post"
    const rewardAmount = await rewardPolicy.getRewardAmount(0);
    expect(rewardAmount).to.equal(20e18);
  });

  it("should allow RewardManager to claim reward once", async function () {
    const [user] = await ethers.getSigners();
    
    // Claim reward for the first time
    await rewardManager.reward(user.address, 0); // ActivityType.Post = 0
    
    // Check if user has claimed the reward
    const hasClaimed = await rewardManager.hasClaimed(user.address, 0);
    expect(hasClaimed).to.be.true;
  });

  it("should not allow double claiming of reward", async function () {
    const [user] = await ethers.getSigners();

    // First claim
    await rewardManager.reward(user.address, 0); // ActivityType.Post = 0

    // Try to claim again
    await expect(rewardManager.reward(user.address, 0)).to.be.revertedWith("Already claimed");
  });
});
