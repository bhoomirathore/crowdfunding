// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint256 public goalAmount;
    uint256 public totalFunds;
    uint256 public deadline;
    bool public goalReached;

    mapping(address => uint256) public contributions;
    address[] public contributors;

    constructor(uint256 _goalAmount, uint256 _durationInDays) {
        owner = msg.sender;
        goalAmount = _goalAmount;
        totalFunds = 0;
        deadline = block.timestamp + (_durationInDays * 1 days);
        goalReached = false;
    }

    // 1️⃣ Contribute to the campaign
    function contribute() public payable {
        require(block.timestamp < deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution must be greater than zero");

        // Track unique contributors
        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;

        if (totalFunds >= goalAmount) {
            goalReached = true;
        }
    }

    // 2️⃣ Withdraw funds (only owner, after goal is reached)
    function withdrawFunds() public {
        require(msg.sender == owner, "Only owner can withdraw funds");
        require(goalReached, "Goal not reached yet");

        uint256 amount = address(this).balance;
        totalFunds = 0;
        payable(owner).transfer(amount);
    }

    // 3️⃣ Refund contributors (if goal not reached and deadline passed)
    function refund() public {
        require(block.timestamp > deadline, "Campaign still active");
        require(!goalReached, "Goal reached, refunds not allowed");
        require(contributions[msg.sender] > 0, "No contributions found");

        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // 4️⃣ Check campaign status
    function getCampaignStatus() public view returns (string memory) {
        if (goalReached) {
            return "✅ Goal reached! Funds can be withdrawn.";
        } else if (block.timestamp > deadline) {
            return "❌ Campaign ended. Goal not reached.";
        } else {
            return "📢 Campaign ongoing. Keep contributing!";
        }
    }

    // 5️⃣ Get number of contributors
    function getTotalContributors() public view returns (uint256) {
        return contributors.length;
    }

    // 6️⃣ Get time left for the campaign
    function getTimeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
}
