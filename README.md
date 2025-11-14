# 🌐 Crowdfunding DApp – Empowering Ideas Through Decentralized Support

## 📖 Project Description
The **Crowdfunding DApp** is a decentralized application built using **Solidity** on the **Ethereum blockchain**.  
It enables users to create or contribute to crowdfunding campaigns securely without depending on third parties or centralized platforms.  
Smart contracts ensure **transparency, fairness, and automation** — contributors can donate ETH to a project, and if the goal isn’t met within the deadline, they automatically get a refund.

---

## 🎯 Project Vision
To establish a **trustworthy and transparent crowdfunding ecosystem** that allows creators, innovators, and organizations to connect directly with their supporters through blockchain technology.  
The vision is to **remove intermediaries**, **enhance transparency**, and **guarantee fair handling of funds** using decentralized systems.

---

## ⚙️ Key Features
- 💸 **Decentralized Fundraising:** Direct contributions using Ethereum with no intermediaries.  
- ⏰ **Deadline-Based Funding:** Campaigns automatically close after a specified duration.  
- 🔒 **Secure Withdrawals:** Only the campaign owner can withdraw funds — and only if the goal is achieved.  
- 💰 **Refund Option:** Contributors can claim a refund automatically if the campaign fails.  
- 📊 **Transparent Transactions:** All contributions and withdrawals are visible on the blockchain.

---

## 🚀 Future Scopes
- 🌍 **Multi-Campaign Support:** Enable multiple campaigns to run simultaneously within the same contract.  
- 🧾 **Milestone-Based Funding:** Funds released in stages as project goals are met.  
- 💬 **Campaign Updates:** Allow creators to post updates and progress reports for contributors.  
- 📱 **Frontend Integration:** Create a React + Web3.js interface for easy interaction.  
- 🔐 **Advanced Security:** Add audits, KYC verification, and protection against re-entrancy attacks.

---

## 💻 Smart Contract Overview

### **Contract Name:** `Crowdfunding.sol`

#### **State Variables**
- `owner` → Address of the campaign creator.  
- `goalAmount` → The total ETH target to be raised.  
- `totalFunds` → Total ETH contributed by all backers.  
- `deadline` → The timestamp marking campaign end.  
- `goalReached` → Boolean to track whether the funding goal has been achieved.  
- `fundsWithdrawn` → Prevents multiple withdrawals by the owner.  
- `contributions` → Mapping to track each contributor’s total donation.

---

### **Functions Overview**

| Function | Description |
|-----------|--------------|
| `constructor(uint256 _goalAmount, uint256 _durationInDays)` | Initializes the campaign goal and duration (in days). |
| `contribute()` | Allows users to contribute Ether to the campaign before the deadline. |
| `withdrawFunds()` | Lets the owner withdraw all funds once the goal is met and before refund eligibility. |
| `getRefund()` | Enable contributors to get their money back if the goal is not reached by the deadline. |
| `getCampaignStatus()` | Returns the current status of the campaign as a readable message. |
7⁷
---

## 🧠 Technologies Used
- **Solidity (v0.8.x)** – Smart contract development language.  
- **Ethereum Blockchain** – For decentralized and transparent transactions.  
- **Remix IDE / Hardhat / Truffle** – To compile, deploy, and test smart contracts.  

---

## ⚙️ Example Deployment on Remix
1. Open [Remix IDE](https://remix.ethereum.org/)  
2. Create a new file named `Crowdfunding.sol` and paste the contract code.  
3. Compile using Solidity version **0.8.0 or above**.  
4. In the **Deploy & Run** tab, enter values:  
   - `_goalAmount`: e.g., `5 ether`  
   - `_durationInDays`: e.g., `7`  
5. Click **Deploy**.  
6. Test the contract using the following functions:  
   - **contribute()** → Send some ETH from multiple accounts.  
   - **getCampaignStatus()** → Check campaign progress.  
   - **withdrawFunds()** → Owner withdraws funds if goal met.  
   - **getRefund()** → Contributors claim refunds if goal not met before deadline.  

---

## 📜 License
This project is licensed under the **MIT License**.  
You are free to modify and use it for personal learning, experimentation, or academic purposes.

---

### 👩‍💻 Author
**Bhoomi Rathore**  
_btech Student | Aspiring Developer | Exploring Blockchain & Space Tech_ 🚀

contract details:0x6825a0f0cFAF6FF3825621b59c2D0a752ad00966
<img width="1920" height="1080" alt="Screenshot (63)" src="https://github.com/user-attachments/assets/048b5b18-b54c-488e-9d61-fda2b0db0c43" />

