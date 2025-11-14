// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Advanced Crowdfunding Platform
 * @dev Enhanced crowdfunding contract with milestones, rewards, and governance features
 * @notice Supports multiple campaigns, milestone-based releases, and contributor voting
 */
contract AdvancedCrowdfunding {
    
    // Structs
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
    
    enum CampaignCategory { Technology, Art, Community, Education, Health, Environment }
    
    // State variables
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    mapping(uint256 => address[]) public campaignContributors;
    mapping(uint256 => Milestone[]) public campaignMilestones;
    mapping(uint256 => RewardTier[]) public campaignRewards;
    mapping(uint256 => mapping(address => bool)) public hasVotedOnMilestone;
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public milestoneVotes;
    mapping(address => uint256[]) public userCampaigns;
    mapping(address => uint256[]) public userContributions;
    
    uint256 public campaignCounter;
    uint256 public platformFeePercentage = 2; // 2% platform fee
    address public platformOwner;
    uint256 public totalPlatformFees;
    
    // Events
    event CampaignCreated(uint256 indexed campaignId, address indexed owner, string title, uint256 goalAmount, uint256 deadline);
    event ContributionMade(uint256 indexed campaignId, address indexed contributor, uint256 amount);
    event GoalReached(uint256 indexed campaignId, uint256 totalFunds);
    event FundsWithdrawn(uint256 indexed campaignId, address indexed owner, uint256 amount);
    event RefundIssued(uint256 indexed campaignId, address indexed contributor, uint256 amount);
    event CampaignCancelled(uint256 indexed campaignId);
    event CampaignExtended(uint256 indexed campaignId, uint256 newDeadline);
    event MilestoneAdded(uint256 indexed campaignId, uint256 milestoneIndex, string description);
    event MilestoneCompleted(uint256 indexed campaignId, uint256 milestoneIndex);
    event MilestoneVoted(uint256 indexed campaignId, uint256 milestoneIndex, address voter, bool vote);
    event RewardTierAdded(uint256 indexed campaignId, uint256 minContribution, string description);
    event EmergencyRefundTriggered(uint256 indexed campaignId);
    
    constructor() {
        platformOwner = msg.sender;
    }
    
    modifier onlyCampaignOwner(uint256 _campaignId) {
        require(campaigns[_campaignId].owner == msg.sender, "Only campaign owner can call this");
        _;
    }
    
    modifier campaignExists(uint256 _campaignId) {
        require(_campaignId > 0 && _campaignId <= campaignCounter, "Campaign does not exist");
        _;
    }
    
    modifier campaignActive(uint256 _campaignId) {
        require(block.timestamp < campaigns[_campaignId].deadline, "Campaign has ended");
        require(!campaigns[_campaignId].cancelled, "Campaign is cancelled");
        _;
    }
    
    /**
     * @dev Create a new crowdfunding campaign
     */
    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _goalAmount,
        uint256 _durationInDays,
        CampaignCategory _category,
        uint256 _minimumContribution
    ) public returns (uint256) {
        require(_goalAmount > 0, "Goal amount must be greater than zero");
        require(_durationInDays > 0, "Duration must be greater than zero");
        require(bytes(_title).length > 0, "Title cannot be empty");
        
        campaignCounter++;
        
        campaigns[campaignCounter] = Campaign({
            owner: msg.sender,
            title: _title,
            description: _description,
            goalAmount: _goalAmount,
            totalFunds: 0,
            deadline: block.timestamp + (_durationInDays * 1 days),
            createdAt: block.timestamp,
            goalReached: false,
            cancelled: false,
            fundsWithdrawn: false,
            category: _category,
            minimumContribution: _minimumContribution
        });
        
        userCampaigns[msg.sender].push(campaignCounter);
        
        emit CampaignCreated(campaignCounter, msg.sender, _title, _goalAmount, campaigns[campaignCounter].deadline);
        
        return campaignCounter;
    }
    
    /**
     * @dev Contribute to a campaign
     */
    function contribute(uint256 _campaignId) 
        public 
        payable 
        campaignExists(_campaignId) 
        campaignActive(_campaignId) 
    {
        Campaign storage campaign = campaigns[_campaignId];
        
        require(msg.value > 0, "Contribution must be greater than zero");
        require(msg.value >= campaign.minimumContribution, "Below minimum contribution");
        
        // Track unique contributors
        if (contributions[_campaignId][msg.sender] == 0) {
            campaignContributors[_campaignId].push(msg.sender);
            userContributions[msg.sender].push(_campaignId);
        }
        
        contributions[_campaignId][msg.sender] += msg.value;
        campaign.totalFunds += msg.value;
        
        // Check and assign reward tiers
        _assignRewardTier(_campaignId, msg.sender);
        
        if (campaign.totalFunds >= campaign.goalAmount && !campaign.goalReached) {
            campaign.goalReached = true;
            emit GoalReached(_campaignId, campaign.totalFunds);
        }
        
        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }
    
    /**
     * @dev NEW: Contribute on behalf of someone else
     */
    function contributeFor(uint256 _campaignId, address _beneficiary) 
        public 
        payable 
        campaignExists(_campaignId) 
        campaignActive(_campaignId) 
    {
        Campaign storage campaign = campaigns[_campaignId];
        
        require(msg.value > 0, "Contribution must be greater than zero");
        require(_beneficiary != address(0), "Invalid beneficiary address");
        
        if (contributions[_campaignId][_beneficiary] == 0) {
            campaignContributors[_campaignId].push(_beneficiary);
            userContributions[_beneficiary].push(_campaignId);
        }
        
        contributions[_campaignId][_beneficiary] += msg.value;
        campaign.totalFunds += msg.value;
        
        _assignRewardTier(_campaignId, _beneficiary);
        
        if (campaign.totalFunds >= campaign.goalAmount && !campaign.goalReached) {
            campaign.goalReached = true;
            emit GoalReached(_campaignId, campaign.totalFunds);
        }
        
        emit ContributionMade(_campaignId, _beneficiary, msg.value);
    }
    
    /**
     * @dev Withdraw funds (only owner, after goal is reached)
     */
    function withdrawFunds(uint256 _campaignId) 
        public 
        campaignExists(_campaignId) 
        onlyCampaignOwner(_campaignId) 
    {
        Campaign storage campaign = campaigns[_campaignId];
        
        require(campaign.goalReached, "Goal not reached yet");
        require(!campaign.fundsWithdrawn, "Funds already withdrawn");
        require(!campaign.cancelled, "Campaign is cancelled");
        
        campaign.fundsWithdrawn = true;
        
        uint256 totalAmount = campaign.totalFunds;
        uint256 platformFee = (totalAmount * platformFeePercentage) / 100;
        uint256 ownerAmount = totalAmount - platformFee;
        
        totalPlatformFees += platformFee;
        
        (bool success1, ) = payable(campaign.owner).call{value: ownerAmount}("");
        require(success1, "Transfer to owner failed");
        
        emit FundsWithdrawn(_campaignId, campaign.owner, ownerAmount);
    }
    
    /**
     * @dev NEW: Withdraw funds by milestone
     */
    function withdrawMilestoneFunds(uint256 _campaignId, uint256 _milestoneIndex) 
        public 
        campaignExists(_campaignId) 
        onlyCampaignOwner(_campaignId) 
    {
        Campaign storage campaign = campaigns[_campaignId];
        Milestone storage milestone = campaignMilestones[_campaignId][_milestoneIndex];
        
        require(milestone.completed, "Milestone not completed");
        require(!milestone.fundsReleased, "Funds already released");
        require(campaign.goalReached, "Campaign goal not reached");
        
        // Check if milestone has majority approval
        uint256 totalVotes = milestone.votesFor + milestone.votesAgainst;
        require(totalVotes > 0, "No votes cast");
        require(milestone.votesFor > milestone.votesAgainst, "Milestone not approved by contributors");
        
        milestone.fundsReleased = true;
        
        uint256 milestoneAmount = milestone.amount;
        uint256 platformFee = (milestoneAmount * platformFeePercentage) / 100;
        uint256 ownerAmount = milestoneAmount - platformFee;
        
        totalPlatformFees += platformFee;
        
        (bool success, ) = payable(campaign.owner).call{value: ownerAmount}("");
        require(success, "Transfer failed");
        
        emit FundsWithdrawn(_campaignId, campaign.owner, ownerAmount);
    }
    
    /**
     * @dev Refund contributors (if goal not reached and deadline passed)
     */
    function refund(uint256 _campaignId) public campaignExists(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        
        require(block.timestamp > campaign.deadline || campaign.cancelled, "Campaign still active");
        require(!campaign.goalReached, "Goal reached, refunds not allowed");
        require(contributions[_campaignId][msg.sender] > 0, "No contributions found");
        
        uint256 amount = contributions[_campaignId][msg.sender];
        contributions[_campaignId][msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Refund transfer failed");
        
        emit RefundIssued(_campaignId, msg.sender, amount);
    }
    
    /**
     * @dev NEW: Batch refund all contributors (emergency only)
     */
    function emergencyRefundAll(uint256 _campaignId) 
        public 
        campaignExists(_campaignId) 
        onlyCampaignOwner(_campaignId) 
    {
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.goalReached || campaign.cancelled, "Cannot refund successful campaign");
        
        address[] memory contributors = campaignContributors[_campaignId];
        
        for (uint256 i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint256 amount = contributions[_campaignId][contributor];
            
            if (amount > 0) {
                contributions[_campaignId][contributor] = 0;
                (bool success, ) = payable(contributor).call{value: amount}("");
                require(success, "Refund failed");
                emit RefundIssued(_campaignId, contributor, amount);
            }
        }
        
        campaign.cancelled = true;
        emit EmergencyRefundTriggered(_campaignId);
    }
    
    /**
     * @dev NEW: Cancel campaign (owner only, before goal reached)
     */
    function cancelCampaign(uint256 _campaignId) 
        public 
        campaignExists(_campaignId) 
        onlyCampaignOwner(_campaignId) 
    {
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.goalReached, "Cannot cancel successful campaign");
        require(!campaign.cancelled, "Already cancelled");
        
        campaign.cancelled = true;
        emit CampaignCancelled(_campaignId);
    }
    
    /**
     * @dev NEW: Extend campaign deadline
     */
    function extendDeadline(uint256 _campaignId, uint256 _additionalDays) 
        public 
        campaignExists(_campaignId) 
        onlyCampaignOwner(_campaignId) 
    {
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.goalReached, "Goal already reached");
        require(!campaign.cancelled, "Campaign is cancelled");
        require(_additionalDays > 0, "Must add at least 1 day");
        
        campaign.deadline += (_additionalDays * 1 days);
        emit CampaignExtended(_campaignId, campaign.deadline);
    }
    
    /**
     * @dev NEW: Add milestone to campaign
     */
    function addMilestone(
        uint256 _campaignId,
        string memory _description,
        uint256 _amount,
        uint256 _deadline
    ) public campaignExists(_campaignId) onlyCampaignOwner(_campaignId) {
        require(_amount > 0, "Milestone amount must be greater than zero");
        require(_deadline > block.timestamp, "Deadline must be in future");
        
        campaignMilestones[_campaignId].push(Milestone({
            description: _description,
            amount: _amount,
            deadline: _deadline,
            completed: false,
            fundsReleased: false,
            votesFor: 0,
            votesAgainst: 0
        }));
        
        emit MilestoneAdded(_campaignId, campaignMilestones[_campaignId].length - 1, _description);
    }
    
    /**
     * @dev NEW: Mark milestone as completed
     */
    function completeMilestone(uint256 _campaignId, uint256 _milestoneIndex) 
        public 
        campaignExists(_campaignId) 
        onlyCampaignOwner(_campaignId) 
    {
        Milestone storage milestone = campaignMilestones[_campaignId][_milestoneIndex];
        require(!milestone.completed, "Milestone already completed");
        
        milestone.completed = true;
        emit MilestoneCompleted(_campaignId, _milestoneIndex);
    }
    
    /**
     * @dev NEW: Vote on milestone completion
     */
    function voteOnMilestone(uint256 _campaignId, uint256 _milestoneIndex, bool _approve) 
        public 
        campaignExists(_campaignId) 
    {
        require(contributions[_campaignId][msg.sender] > 0, "Only contributors can vote");
        require(!milestoneVotes[_campaignId][_milestoneIndex][msg.sender], "Already voted");
        
        Milestone storage milestone = campaignMilestones[_campaignId][_milestoneIndex];
        require(milestone.completed, "Milestone not marked as completed yet");
        
        milestoneVotes[_campaignId][_milestoneIndex][msg.sender] = true;
        
        if (_approve) {
            milestone.votesFor++;
        } else {
            milestone.votesAgainst++;
        }
        
        emit MilestoneVoted(_campaignId, _milestoneIndex, msg.sender, _approve);
    }
    
    /**
     * @dev NEW: Add reward tier
     */
    function addRewardTier(
        uint256 _campaignId,
        uint256 _minContribution,
        string memory _rewardDescription,
        uint256 _maxBackers
    ) public campaignExists(_campaignId) onlyCampaignOwner(_campaignId) {
        require(_minContribution > 0, "Minimum contribution must be greater than zero");
        
        campaignRewards[_campaignId].push(RewardTier({
            minContribution: _minContribution,
            rewardDescription: _rewardDescription,
            maxBackers: _maxBackers,
            currentBackers: 0
        }));
        
        emit RewardTierAdded(_campaignId, _minContribution, _rewardDescription);
    }
    
    /**
     * @dev Internal function to assign reward tier
     */
    function _assignRewardTier(uint256 _campaignId, address _contributor) internal {
        uint256 totalContribution = contributions[_campaignId][_contributor];
        RewardTier[] storage rewards = campaignRewards[_campaignId];
        
        for (uint256 i = 0; i < rewards.length; i++) {
            if (totalContribution >= rewards[i].minContribution && 
                (rewards[i].maxBackers == 0 || rewards[i].currentBackers < rewards[i].maxBackers)) {
                rewards[i].currentBackers++;
                break;
            }
        }
    }
    
    /**
     * @dev NEW: Update platform fee (platform owner only)
     */
    function updatePlatformFee(uint256 _newFeePercentage) public {
        require(msg.sender == platformOwner, "Only platform owner can update fee");
        require(_newFeePercentage <= 10, "Fee cannot exceed 10%");
        platformFeePercentage = _newFeePercentage;
    }
    
    /**
     * @dev NEW: Withdraw platform fees
     */
    function withdrawPlatformFees() public {
        require(msg.sender == platformOwner, "Only platform owner can withdraw fees");
        uint256 amount = totalPlatformFees;
        totalPlatformFees = 0;
        
        (bool success, ) = payable(platformOwner).call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    // View Functions
    
    /**
     * @dev Get campaign status
     */
    function getCampaignStatus(uint256 _campaignId) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (string memory) 
    {
        Campaign memory campaign = campaigns[_campaignId];
        
        if (campaign.cancelled) {
            return "Cancelled - Refunds available";
        } else if (campaign.goalReached) {
            return "Goal Reached - Successful!";
        } else if (block.timestamp > campaign.deadline) {
            return "Campaign Ended - Goal not reached";
        } else {
            return "Campaign Active - Accepting contributions";
        }
    }
    
    /**
     * @dev Get total number of contributors
     */
    function getTotalContributors(uint256 _campaignId) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (uint256) 
    {
        return campaignContributors[_campaignId].length;
    }
    
    /**
     * @dev Get time left for campaign
     */
    function getTimeLeft(uint256 _campaignId) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (uint256) 
    {
        Campaign memory campaign = campaigns[_campaignId];
        if (block.timestamp >= campaign.deadline) {
            return 0;
        }
        return campaign.deadline - block.timestamp;
    }
    
    /**
     * @dev Get contribution amount of any contributor
     */
    function getContributionOf(uint256 _campaignId, address _user) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (uint256) 
    {
        return contributions[_campaignId][_user];
    }
    
    /**
     * @dev NEW: Get all contributors for a campaign
     */
    function getAllContributors(uint256 _campaignId) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (address[] memory) 
    {
        return campaignContributors[_campaignId];
    }
    
    /**
     * @dev NEW: Get campaign progress percentage
     */
    function getCampaignProgress(uint256 _campaignId) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (uint256) 
    {
        Campaign memory campaign = campaigns[_campaignId];
        if (campaign.goalAmount == 0) return 0;
        return (campaign.totalFunds * 100) / campaign.goalAmount;
    }
    
    /**
     * @dev NEW: Get all campaigns created by a user
     */
    function getUserCampaigns(address _user) public view returns (uint256[] memory) {
        return userCampaigns[_user];
    }
    
    /**
     * @dev NEW: Get all campaigns user has contributed to
     */
    function getUserContributions(address _user) public view returns (uint256[] memory) {
        return userContributions[_user];
    }
    
    /**
     * @dev NEW: Get campaign milestones
     */
    function getCampaignMilestones(uint256 _campaignId) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (Milestone[] memory) 
    {
        return campaignMilestones[_campaignId];
    }
    
    /**
     * @dev NEW: Get campaign rewards
     */
    function getCampaignRewards(uint256 _campaignId) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (RewardTier[] memory) 
    {
        return campaignRewards[_campaignId];
    }
    
    /**
     * @dev NEW: Get detailed campaign info
     */
    function getCampaignDetails(uint256 _campaignId) 
        public 
        view 
        campaignExists(_campaignId) 
        returns (
            address owner,
            string memory title,
            string memory description,
            uint256 goalAmount,
            uint256 totalFunds,
            uint256 deadline,
            bool goalReached,
            bool cancelled,
            uint256 contributorsCount,
            uint256 progress
        ) 
    {
        Campaign memory campaign = campaigns[_campaignId];
        return (
            campaign.owner,
            campaign.title,
            campaign.description,
            campaign.goalAmount,
            campaign.totalFunds,
            campaign.deadline,
            campaign.goalReached,
            campaign.cancelled,
            campaignContributors[_campaignId].length,
            getCampaignProgress(_campaignId)
        );
    }
    
    /**
     * @dev NEW: Get platform statistics
     */
    function getPlatformStats() public view returns (
        uint256 totalCampaigns,
        uint256 totalFeesCollected,
        uint256 platformFee
    ) {
        return (campaignCounter, totalPlatformFees, platformFeePercentage);
    }
}
