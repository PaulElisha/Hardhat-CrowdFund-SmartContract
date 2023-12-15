// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFund {

    event Launched(
        uint id, 
        address indexed creator, 
        uint goal, 
        uint32 startAt, 
        uint32 endAt
    );

    event Pledged(
        uint indexed id,
        address indexed caller,
        uint amount
    );

    event Unpledged(
        uint indexed id,
        address indexed caller,
        uint amount
    );

    event Cancel(
        uint id, 
        address indexed sender, 
        uint amount
    );

    event Claim(
        uint id
    );

    event Refund(
        uint id, 
        address indexed sender,
        uint amount
    );

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 private immutable i_token;
    mapping(uint => Campaign) public s_campaigns;
    uint private s_count;
    mapping (uint => mapping (address => uint)) private s_amountPledged;

    constructor(address token) {
        i_token = IERC20(token);
    }

    function launch(
        uint goal,
        uint32 startAt,
        uint32 endAt
    ) external {
        require(startAt >= block.timestamp, "StartingTime: Invalid");
        require(endAt >= startAt, "EndingTime: Invalid" );
        require(endAt <= block.timestamp + 90 days, "MaxDuration: Invalid");

        s_count = s_count + 1;
        s_campaigns[s_count] = Campaign({
            creator: msg.sender,
            goal: goal,
            pledged: 0,
            startAt: startAt,
            endAt: endAt,
            claimed: false
        });

        emit Launched(
            s_count, 
            msg.sender, 
            goal, 
            startAt, 
            endAt
        );
    }

    function cancel(uint id) external {
        Campaign memory campaign = s_campaigns[id];
        require(msg.sender == campaign.creator, "Not Creator");
        require(block.timestamp < campaign.startAt, "Campaign Started");

        delete s_campaigns[id];

        emit Cancel(
            id,
            msg.sender,
            s_amountPledged,
        );
    }

    function pledge(uint id, uint amount) external {
        Campaign storage campaign = s_campaigns[id];
        require(block.timestamp >= campaign.startAt, "Not Started");
        require(block.timestamp <= campaign.endAt, "Ended!"); 

        campaign.pledged += amount;
        s_amountPledged[id][msg.sender] += amount;
        i_token.transferFrom(msg.sender, address(this), amount);

        emit Pledged(
            id, 
            msg.sender, 
            amount
        );
    }

    function unpledge(uint id, uint amount) external {
        Campaign storage campaign = s_campaigns[id];
        require(block.timestamp <= campaign.endAt, "Ended!");

        campaign.pledged -= amount;
        s_amountPledged[id][msg.sender] -= amount;
        i_token.transfer(msg.sender, amount);

        emit Unpledged(
            id, 
            msg.sender, 
            amount
        );
    }

    function claim(uint id) external {
        Campaign storage campaign = s_campaigns[id];
        require(msg.sender == campaign.creator, "Not Creator");
        require(block.timestamp > campaign.endAt, "Ended!");
        require(campaign.pledged >= campaign.goal, "Pledge is less than goal");
        require(!campaign.claimed, "Claimed!");

        campaign.claimed = true;
        i_token.transfer(msg.sender, campaign.pledged);

        emit Claim(
            id
        );
    }   

    function refund(uint id)  external {
        Campaign storage campaign = s_campaigns[id];
        require(block.timestamp > campaign.endAt, "Ended!");
        require(campaign.pledged < campaign.goal, "Pledge is less than goal");

        uint bal = s_amountPledged[id][msg.sender];
        s_amountPledged[id][msg.sender] = 0;
        i_token.transfer(msg.sender, bal);

        emit Refund(
            id, 
            msg.sender, 
            bal
        );
        
    }

    func
}

