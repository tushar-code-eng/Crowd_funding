// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract lottery
{
    address public manager;
    address payable[] public participants;

    constructor()
    {
        manager = msg.sender;//this will set the address of this contract to manager
    }
    receive() external payable   //this function transfer some amount of ether in this contract from participants and this function is unique is only made like this and their is only one function of this kind in the whole contract and it takes no argument
    {   
        require(msg.sender!=manager);
        require(msg.value>=2 ether);
        participants.push(payable(msg.sender)); // this will push the addres of the participant contract
    }

    function getBalance() public view returns(uint)
    {   
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() public view returns(uint)
    {
        return uint(keccak256(abi.encodePacked(block.timestamp,participants.length)));
    }

    function selectwinner() public
    {
        require(msg.sender==manager);
        require(participants.length>=3);
        uint r=random();
        address payable winner;
        uint index = r % participants.length; // select random address array of participants
        winner=participants[index];
        winner.transfer(getBalance()); // shift all the money to the winner account
        participants = new address payable[](0); // reseting the array that means we are putting our participants array to zero.        
    }
}