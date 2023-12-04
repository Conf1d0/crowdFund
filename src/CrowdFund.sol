// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//User creates a campaign. +
//Users can pledge, transferring their token to a campaign.
//After the campaign ends, campaign creator can claim the funds if total amount pledged is more than the campaign goal.
//Otherwise, campaign did not reach it's goal, users can withdraw their pledge.

contract CrowdFund {
    struct crowdInfo {
        bool isActive;
        address creator;
        string name;
        uint256 goal;
        uint256 maximumMoney;
        uint256 duration;
        uint256 currentMoney;
    }
    uint256 public cid;
    address public owner;
    mapping(uint256 => crowdInfo) public idToCrowd;
    mapping(uint256 => mapping(address => uint256)) idToAddress; // id => address => money
    mapping(uint256 => uint256) contrubutorCount; // id => contrubutor

    event campaignHasFinished(
        uint256 capaignId_,
        uint256 goal_,
        uint256 currentMoney_
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        owner = msg.sender;
        _;
    }

    function createCampaign(
        string calldata name_,
        address creator_,
        uint256 goal_,
        uint256 maximumMoney_,
        uint256 duration_
    ) public onlyOwner {
        crowdInfo memory ci = crowdInfo(
            true,
            creator_,
            name_,
            goal_,
            maximumMoney_,
            duration_ + block.timestamp,
            0
        );
        idToCrowd[cid] = ci;
        cid++;
    }

    function contrubuteCampaign(uint256 cid_) public payable {
        require(msg.value > 0 ,"ETH is zero");
        require(idToCrowd[cid_].isActive, "CrowdFund is inactive!");
       
      
        idToCrowd[cid_].currentMoney += msg.value;
        idToAddress[cid_][msg.sender] = msg.value;
        contrubutorCount[cid_] += 1;
    }

    function finishCampaign(uint256 cid_) external onlyOwner {
        require(idToCrowd[cid_].isActive, "CrowdFund is inactive!");
        require(
            block.timestamp > idToCrowd[cid_].duration,
            "Crowdfund duration is not finished yet"
        );

        idToCrowd[cid_].isActive = false;

        if(idToCrowd[cid_].currentMoney >= idToCrowd[cid_].goal) 
        {
        
        (bool success, ) = address(idToCrowd[cid_].creator).call{
            value: idToCrowd[cid_].currentMoney
        }("");
        require(success);
        
        }

        emit campaignHasFinished(
            cid_,
            idToCrowd[cid_].goal,
            idToCrowd[cid_].currentMoney
        );
    }

    function paybackCampaign(uint cid_) external {
        require(idToCrowd[cid_].isActive == false, "CrowdFund is already active!");

        require(idToAddress[cid_][msg.sender] != 0, "You have no contribute!");

        require(idToCrowd[cid_].currentMoney < idToCrowd[cid_].goal,"Goal has been reached, you can not take your money back"); 

        uint amount = idToAddress[cid_][msg.sender];
        idToAddress[cid_][msg.sender] = 0;
        
        (bool success, ) = address(msg.sender).call{
            value: amount
        }("");
        require(success, "send is unsuccessfull");
    }

    /* GETTERS */

    function getname(uint cid_) external view returns (string memory s) {
        s = idToCrowd[cid_].name;
    }

    function getMoney(uint cid_) external view returns (uint256 s) {
        s = idToCrowd[cid_].currentMoney;
    }

    function getStatus(uint cid_) external view returns (bool b) {
        b = idToCrowd[cid_].isActive;
    }

    function getContrubutedAmount(uint cid_) external view returns (uint256 u) {
        u = idToAddress[cid_][msg.sender];
    }

    function balanceof() external view returns(uint256 s) {
        s= address(this).balance;
    }
}
