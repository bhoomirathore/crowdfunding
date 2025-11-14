# 🚀 Advanced Crowdfunding Platform

A smart contract for decentralized crowdfunding with milestones, rewards, and voting features.

## Features

- Create crowdfunding campaigns with goals and deadlines
- Contribute ETH to campaigns
- Milestone-based fund releases
- Reward tiers for contributors
- Contributor voting on milestones
- Automatic refunds if goal not reached
- Campaign categories (Tech, Art, Education, etc.)

## Installation

```bash
# Clone repository
git clone https://github.com/yourusername/advanced-crowdfunding.git
cd advanced-crowdfunding

# Install dependencies
npm install

# Compile contract
npx hardhat compile

# Run tests
npx hardhat test
```

## Quick Start

### Create a Campaign

```javascript
await crowdfunding.createCampaign(
  "My Project",                      // title
  "Project description",             // description
  ethers.utils.parseEther("100"),    // goal: 100 ETH
  30,                                 // duration: 30 days
  0,                                  // category: Technology
  ethers.utils.parseEther("0.1")     // minimum: 0.1 ETH
);
```

### Contribute to Campaign

```javascript
await crowdfunding.contribute(campaignId, {
  value: ethers.utils.parseEther("1.0")
});
```

### Add Milestone

```javascript
await crowdfunding.addMilestone(
  campaignId,
  "Complete prototype",
  ethers.utils.parseEther("30"),
  deadlineTimestamp
);
```

### Claim Refund (if goal not reached)

```javascript
await crowdfunding.refund(campaignId);
```

## Main Functions

| Function | Description |
|----------|-------------|
| `createCampaign()` | Start a new campaign |
| `contribute()` | Donate to a campaign |
| `addMilestone()` | Add milestone (owner only) |
| `voteOnMilestone()` | Vote on milestone completion |
| `withdrawFunds()` | Withdraw funds (owner, after goal reached) |
| `refund()` | Get refund (if goal not reached) |
| `getCampaignStatus()` | Check campaign status |
| `getCampaignProgress()` | Get funding percentage |

## Deployment

```bash
# Deploy to Sepolia testnet
npx hardhat run scripts/deploy.js --network sepolia

# Verify on Etherscan
npx hardhat verify --network sepolia CONTRACT_ADDRESS
```

## Environment Setup

Create `.env` file:

```
PRIVATE_KEY=your_private_key
SEPOLIA_RPC_URL=your_alchemy_or_infura_url
ETHERSCAN_API_KEY=your_etherscan_key
```

## Testing

```bash
npx hardhat test
```

## Security

⚠️ **Not audited** - Use at your own risk. Test thoroughly before mainnet deployment.
