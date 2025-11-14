# 🚀 Advanced Crowdfunding Platform Smart Contract

A feature-rich Solidity smart contract for decentralized crowdfunding with milestone-based fund releases, reward tiers, contributor voting, and comprehensive campaign management.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage Guide](#usage-guide)
- [Contract Functions](#contract-functions)
- [Campaign Workflow](#campaign-workflow)
- [Security Features](#security-features)
- [Testing](#testing)
- [Deployment](#deployment)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

The **Advanced Crowdfunding Platform** is a next-generation decentralized crowdfunding solution built on Ethereum. It enables creators to launch campaigns with sophisticated features like milestone-based fund releases, reward tiers, and democratic contributor voting.

### Why This Platform?

- ✅ **Transparent**: All transactions on blockchain
- ✅ **Secure**: Multi-layer security with refund mechanisms
- ✅ **Flexible**: Support for various campaign types
- ✅ **Democratic**: Contributors vote on milestone completions
- ✅ **Rewarding**: Built-in reward tier system

## ✨ Features

### Core Features
- 📊 **Campaign Creation**: Launch campaigns with goals, deadlines, and categories
- 💰 **Contribution System**: Easy contribution with minimum thresholds
- 🎯 **Goal Tracking**: Real-time progress monitoring
- 💸 **Refund Mechanism**: Automatic refunds if goals aren't met
- 👥 **Contributor Tracking**: Complete contributor management

### New Enhanced Features

#### 🎖️ Milestone Management
- Create milestone-based fund releases
- Contributors vote on milestone completion
- Gradual fund release instead of lump sum
- Increased accountability for campaign owners

#### 🎁 Reward Tiers
- Multiple reward levels based on contribution amount
- Limited availability rewards for exclusivity
- Automatic tier assignment on contribution
- Flexible reward descriptions

#### 🗳️ Contributor Governance
- Democratic voting on milestones
- Vote weight based on contribution
- Transparent approval process
- Community-driven fund releases

#### 🛡️ Advanced Safety
- Campaign cancellation by owner
- Emergency refund for all contributors
- Deadline extension capability
- Platform fee management (2% default)

#### 📊 Analytics & Tracking
- Campaign progress percentage
- Time remaining calculations
- Contributor statistics
- Platform-wide metrics

#### 🎨 Campaign Categories
- Technology
- Art
- Community
- Education
- Health
- Environment

## 🚀 Installation

### Prerequisites

```bash
Node.js: v16.0.0 or higher
Hardhat: v2.0.0 or higher
Solidity: ^0.8.20
```

### Setup Steps

```bash
# Clone the repository
git clone https://github.com/yourusername/advanced-crowdfunding.git
cd advanced-crowdfunding

# Install dependencies
npm install

# Install Hardhat and plugins
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test
```

## 💻 Usage Guide

### 1. Creating a Campaign

```javascript
const { ethers } = require("hardhat");

async function createCampaign() {
  const Crowdfunding = await ethers.getContractFactory("AdvancedCrowdfunding");
  const crowdfunding = await Crowdfunding.deploy();
  await crowdfunding.deployed();
  
  const tx = await crowdfunding.createCampaign(
    "My Awesome Project",                    // title
    "Building the future of decentralized...", // description
    ethers.utils.parseEther("100"),          // goal: 100 ETH
    30,                                       // duration: 30 days
    0,                                        // category: Technology
    ethers.utils.parseEther("0.1")           // minimum: 0.1 ETH
  );
  
  const receipt = await tx.wait();
  console.log("Campaign created:", receipt.events[0].args.campaignId);
}
```

### 2. Adding Milestones

```javascript
async function addMilestones(campaignId) {
  // Milestone 1: Initial Development
  await crowdfunding.addMilestone(
    campaignId,
    "Complete prototype development",
    ethers.utils.parseEther("30"),
    Math.floor(Date.now() / 1000) + 2592000 // 30 days
  );
  
  // Milestone 2: Beta Testing
  await crowdfunding.addMilestone(
    campaignId,
    "Beta testing phase completion",
    ethers.utils.parseEther("40"),
    Math.floor(Date.now() / 1000) + 5184000 // 60 days
  );
  
  // Milestone 3: Final Release
  await crowdfunding.addMilestone(
    campaignId,
    "Production release and marketing",
    ethers.utils.parseEther("30"),
    Math.floor(Date.now() / 1000) + 7776000 // 90 days
  );
}
```

### 3. Setting Up Reward Tiers

```javascript
async function setupRewards(campaignId) {
  // Bronze Tier
  await crowdfunding.addRewardTier(
    campaignId,
    ethers.utils.parseEther("0.1"),
    "Early access + Thank you message",
    100 // max 100 backers
  );
  
  // Silver Tier
  await crowdfunding.addRewardTier(
    campaignId,
    ethers.utils.parseEther("1"),
    "All bronze rewards + Exclusive NFT",
    50
  );
  
  // Gold Tier
  await crowdfunding.addRewardTier(
    campaignId,
    ethers.utils.parseEther("5"),
    "All silver rewards + Product co-creation",
    10
  );
}
```

### 4. Contributing to a Campaign

```javascript
// Simple contribution
await crowdfunding.contribute(campaignId, {
  value: ethers.utils.parseEther("1.0")
});

// Contribute on behalf of someone else
await crowdfunding.contributeFor(
  campaignId,
  "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  { value: ethers.utils.parseEther("2.0") }
);
```

### 5. Milestone Voting & Fund Release

```javascript
// Mark milestone as completed (owner)
await crowdfunding.completeMilestone(campaignId, 0);

// Contributors vote on completion
await crowdfunding.voteOnMilestone(
  campaignId, 
  0,      // milestone index
  true    // approve
);

// Withdraw milestone funds after approval
await crowdfunding.withdrawMilestoneFunds(campaignId, 0);
```

## 📚 Contract Functions

### Campaign Management

| Function | Description | Access |
|----------|-------------|--------|
| `createCampaign()` | Create a new campaign | Public |
| `cancelCampaign()` | Cancel active campaign | Owner |
| `extendDeadline()` | Extend campaign duration | Owner |
| `getCampaignStatus()` | Get current status | Public View |
| `getCampaignProgress()` | Get funding progress % | Public View |
| `getCampaignDetails()` | Get complete info | Public View |

### Contribution Functions

| Function | Description | Access |
|----------|-------------|--------|
| `contribute()` | Make a contribution | Public Payable |
| `contributeFor()` | Contribute for someone else | Public Payable |
| `refund()` | Claim refund | Contributors |
| `emergencyRefundAll()` | Refund all contributors | Owner |
| `getContributionOf()` | Check contribution amount | Public View |

### Milestone Management

| Function | Description | Access |
|----------|-------------|--------|
| `addMilestone()` | Add new milestone | Owner |
| `completeMilestone()` | Mark milestone done | Owner |
| `voteOnMilestone()` | Vote on completion | Contributors |
| `withdrawMilestoneFunds()` | Release milestone funds | Owner |
| `getCampaignMilestones()` | Get all milestones | Public View |

### Reward System

| Function | Description | Access |
|----------|-------------|--------|
| `addRewardTier()` | Create reward tier | Owner |
| `getCampaignRewards()` | Get all rewards | Public View |

### Fund Management

| Function | Description | Access |
|----------|-------------|--------|
| `withdrawFunds()` | Withdraw all funds (no milestones) | Owner |
| `withdrawMilestoneFunds()` | Withdraw milestone funds | Owner |
| `withdrawPlatformFees()` | Withdraw platform fees | Platform Owner |

### Query Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `getTotalContributors()` | Count of contributors | uint256 |
| `getTimeLeft()` | Seconds until deadline | uint256 |
| `getAllContributors()` | List of contributors | address[] |
| `getUserCampaigns()` | Campaigns by user | uint256[] |
| `getUserContributions()` | User's contributions | uint256[] |
| `getPlatformStats()` | Platform statistics | Multiple |

## 🔄 Campaign Workflow

### Standard Campaign Flow

```
1. Create Campaign
   ↓
2. Add Milestones (optional)
   ↓
3. Add Reward Tiers (optional)
   ↓
4. Campaign Goes Live
   ↓
5. Contributors Donate
   ↓
6a. Goal Reached → Withdraw Funds
6b. Goal Not Reached → Refunds Available
```

### Milestone-Based Flow

```
1. Create Campaign with Milestones
   ↓
2. Contributors Fund Campaign
   ↓
3. Goal Reached
   ↓
4. Owner Completes Milestone 1
   ↓
5. Contributors Vote on Completion
   ↓
6. Majority Approval → Funds Released
   ↓
7. Repeat for Each Milestone
```

## 🔒 Security Features

### Built-in Protections

- ✅ **Reentrancy Guard**: All external calls use CEI pattern
- ✅ **Access Control**: Function-level permissions
- ✅ **Refund Safety**: Automatic refunds for failed campaigns
- ✅ **Validation Checks**: Comprehensive input validation
- ✅ **Emergency Controls**: Owner can trigger emergency refunds

### Best Practices

1. **Test on Testnet First**: Always deploy to Goerli/Sepolia first
2. **Small Initial Goals**: Start with achievable targets
3. **Clear Milestones**: Define specific, measurable milestones
4. **Regular Updates**: Keep contributors informed
5. **Secure Keys**: Use hardware wallets for campaign owners

### Known Limitations

- ⚠️ Timestamp dependency (use block.timestamp cautiously)
- ⚠️ Gas costs for batch operations
- ⚠️ No ERC-20 token support (ETH only)
- ⚠️ Platform fee not adjustable per campaign

## 🧪 Testing

### Run Test Suite

```bash
# Run all tests
npx hardhat test

# Run specific test file
npx hardhat test test/Crowdfunding.test.js

# Run with gas reporting
REPORT_GAS=true npx hardhat test

# Run coverage
npx hardhat coverage
```

### Example Test Cases

```javascript
describe("AdvancedCrowdfunding", function () {
  
  it("Should create a campaign successfully", async function () {
    const tx = await crowdfunding.createCampaign(
      "Test Campaign",
      "Description",
      ethers.utils.parseEther("10"),
      30,
      0,
      ethers.utils.parseEther("0.1")
    );
    expect(await crowdfunding.campaignCounter()).to.equal(1);
  });
  
  it("Should accept contributions", async function () {
    await crowdfunding.contribute(1, { 
      value: ethers.utils.parseEther("1") 
    });
    const contrib = await crowdfunding.getContributionOf(1, addr1.address);
    expect(contrib).to.equal(ethers.utils.parseEther("1"));
  });
  
  it("Should refund if goal not reached", async function () {
    // Fast forward time past deadline
    await ethers.provider.send("evm_increaseTime", [31 * 24 * 60 * 60]);
    await ethers.provider.send("evm_mine");
    
    const balanceBefore = await addr1.getBalance();
    await crowdfunding.connect(addr1).refund(1);
    const balanceAfter = await addr1.getBalance();
    
    expect(balanceAfter).to.be.gt(balanceBefore);
  });
  
  it("Should allow milestone voting", async function () {
    await crowdfunding.addMilestone(1, "Milestone 1", 
      ethers.utils.parseEther("5"), futureTime);
    await crowdfunding.completeMilestone(1, 0);
    await crowdfunding.connect(addr1).voteOnMilestone(1, 0, true);
    
    const milestones = await crowdfunding.getCampaignMilestones(1);
    expect(milestones[0].votesFor).to.equal(1);
  });
});
```

## 🌐 Deployment

### Deploy to Testnet (Sepolia)

```javascript
// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  const Crowdfunding = await hre.ethers.getContractFactory("AdvancedCrowdfunding");
  const crowdfunding = await Crowdfunding.deploy();
  
  await crowdfunding.deployed();
  
  console.log("Crowdfunding deployed to:", crowdfunding.address);
  
  // Verify on Etherscan
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("Waiting for block confirmations...");
    await crowdfunding.deployTransaction.wait(6);
    await hre.run("verify:verify", {
      address: crowdfunding.address,
      constructorArguments: [],
    });
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

### Deployment Command

```bash
# Deploy to Sepolia
npx hardhat run scripts/deploy.js --network sepolia

# Deploy to mainnet (use with caution!)
npx hardhat run scripts/deploy.js --network mainnet
```

### Environment Configuration

Create `.env` file:

```env
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
ETHERSCAN_API_KEY=your_etherscan_api_key
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
```

### Hardhat Config

```javascript
// hardhat.config.js
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    },
    mainnet: {
      url: process.env.MAINNET_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};
```

## 📊 Gas Estimates

| Function | Estimated Gas | ETH (at 50 Gwei) |
|----------|---------------|------------------|
| createCampaign | ~250,000 | ~0.0125 ETH |
| contribute | ~80,000 | ~0.004 ETH |
| addMilestone | ~120,000 | ~0.006 ETH |
| addRewardTier | ~100,000 | ~0.005 ETH |
| voteOnMilestone | ~60,000 | ~0.003 ETH |
| withdrawFunds | ~75,000 | ~0.00375 ETH |
| refund | ~50,000 | ~0.0025 ETH |

*Note: Gas prices vary based on network congestion*

## 📖 API Reference

### Events

```solidity
event CampaignCreated(uint256 indexed campaignId, address indexed owner, string title, uint256 goalAmount, uint256 deadline);
event ContributionMade(uint256 indexed campaignId, address indexed contributor, uint256 amount);
event GoalReached(uint256 indexed campaignId, uint256 totalFunds);
event FundsWithdrawn(uint256 indexed campaignId, address indexed owner, uint256 amount);
event RefundIssued(uint256 indexed campaignId, address indexed contributor, uint256 amount);
event CampaignCancelled(uint256 indexed campaignId);
event MilestoneCompleted(uint256 indexed campaignId, uint256 milestoneIndex);
event MilestoneVoted(uint256 indexed campaignId, uint256 milestoneIndex, address voter, bool vote);
```

### Structs

```solidity
struct Campaign {
    address owner;
    string title;
    string description;
    uint256 goalAmount;
    uint256 totalFunds;
    uint256 deadline;
    uint256 createdAt;
    bool goalReached;
    bool cancelled;
    bool fundsWithdrawn;
    CampaignCategory category;
    uint256 minimumContribution;
}

struct Milestone {
    string description;
    uint256 amount;
    uint256 deadline;
    bool completed;
    bool fundsReleased;
    uint256 votesFor;
    uint256 votesAgainst;
}

struct RewardTier {
    uint256 minContribution;
    string rewardDescription;
    uint256 maxBackers;
    uint256 currentBackers;
}
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contribution Guidelines

- Write clear, commented code
- Add tests for new features
- Update documentation
- Follow Solidity style guide
- Ensure all tests pass

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what's best for the community

## 🗺️ Roadmap

### Phase 1: Core Platform (Completed ✅)
- [x] Basic campaign creation
- [x] Contribution system
- [x] Refund mechanism
- [x] Goal tracking

### Phase 2: Enhanced Features (Completed ✅)
- [x] Milestone management
- [x] Reward tiers
- [x] Contributor voting
- [x] Campaign analytics

### Phase 3: Advanced Features (In Progress 🚧)
- [ ] ERC-20 token support
- [ ] NFT reward integration
- [ ] Multi-signature withdrawals
- [ ] Campaign templates

### Phase 4: Platform Expansion (Planned 📋)
- [ ] Mobile app integration
- [ ] Social features
- [ ] Recommendation engine
- [ ] Advanced analytics dashboard

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Advanced Crowdfunding Platform

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software...
```

## 🙏 Acknowledgments

- Ethereum Foundation for blockchain infrastructure
- OpenZeppelin for security patterns
- Hardhat team for development tools
- Community contributors and supporters

## ⚠️ Disclaimer

**Important**: This smart contract is provided for educational and development purposes. While security best practices have been followed, the contract has not been professionally audited. Use at your own risk. Always:

- Test thoroughly on testnets
- Consider getting a professional audit before mainnet deployment
- Never invest more than you can afford to lose
- Do your own research (DYOR)

---

**Built with ❤️ for decentralized fundraising**

**Version**: 1.0.0  
**Last Updated**: November 2025  
**Solidity Version**: ^0.8.20
