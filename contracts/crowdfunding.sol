// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint256 public goalAmount;
    uint256 public totalFunds;

    mapping(address => uint256) public contributions;

    constructor(uint256 _goalAmount) {
        owner = msg.sender;
        goalAmount = _goalAmount;
        totalFunds = 0;
    }

    // 1️⃣ Function to contribute to the campaign
    function contribute() public payable {
        require(msg.value > 0, "Contribution must be greater than zero");
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
    }

    // 2️⃣ Function to withdraw funds (only by owner)
    function withdrawFunds() public {
        require(msg.sender == owner, "Only owner can withdraw funds");
        require(totalFunds >= goalAmount, "Goal not reached yet");

        uint256 amount = address(this).balance;
        totalFunds = 0;
        payable(owner).transfer(amount);
    }

    // 3️⃣ Function to check campaign status
    function getCampaignStatus() public view returns (string memory) {
        if (totalFunds >= goalAmount) {
            return "Goal reached! Funds can be withdrawn.";
        } else {
            return "Campaign ongoing. Keep contributing!";
        }
    }
}

