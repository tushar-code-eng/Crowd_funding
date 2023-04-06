// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract Crowd_funding
{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedamt;
    uint public noofContributors;

    struct Request // this is structure which will be made by manager to use the fund for a cause
    {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) public requests; //this will map each number to the purpose of request
    uint public numRequests; // we use this because mapping is not iterable so by doing this we will be able to itterate over the map

    constructor(uint _target,uint _deadline)
    {
        target=_target;
        deadline=block.timestamp+_deadline; // block.timestamp woll give us the timestamp of the blockchain and deadline will be in seconds
        minimumContribution = 100 wei;
        manager=msg.sender;
    }

    function transferETH() public payable
    {
        require(block.timestamp<deadline,"Deadline is crossed");
        require(msg.value>=minimumContribution,"Contribution is less");

        if(contributors[msg.sender]==0) // through this we check whether a contributor is new or old as new contributor will have initial fund 0.
        {
            noofContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedamt+=msg.value;
    }
    function getBal() public onlyManager view returns(uint)
    {
        return address(this).balance;//this line returns the balance of that address which is selected at the time of deploying that means the address of the manager.
    }

    function refund() public 
    {
        require(block.timestamp>deadline && raisedamt<target,"You are not eligible for refund");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;

    }
    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can access");
        _;
    }
    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManager // by writting onlyManager means the things written in onlyManager modifier will by implimented first, this is how modiefier works
    {
        Request storage newRequest = requests[numRequests]; // we use storage instead memory bec data type is an object of structure and in using object of structure as data type we will use storage
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }
    function voteRequests(uint _requestNo) public
    {
        require(contributors[msg.sender]>0,"For voting first you must be a contributor");
        Request storage thisRequest=requests[_requestNo]; //it will store the vote request for a particular work like we will be voting for different charity works so this will store whether we have voted for a particular donation
        require(thisRequest.voters[msg.sender]==false,"You already voted");// this we added to check if the voter has not already voted
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyManager
    {
        require(raisedamt>=target);
        Request storage thisRequest =requests[_requestNo];
        require(thisRequest.completed==false,"This request is already completed");
        require(thisRequest.noOfVoters>noofContributors/2,"Majority not in favor");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed==true;
    }
}