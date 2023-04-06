// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract EventOrganization
{
    struct Event
    {
        address oraganizer;
        string name;
        uint date;
        uint prize;
        uint noOfTickets;
        uint TicketRemain;
    }

    mapping(uint=>Event) public events; // this mapping will hold differnet types of events
    mapping(address=>mapping(uint=>uint)) public tickets; // this mapping will hold that which address has got amount of ticket number of which event.
    uint public nextId;

    function createEvent(string memory _name,uint _date,uint _prize,uint _noOfTickets) external
    {
        require(_date>block.timestamp,"Can only organise event for future dates");
        require(_noOfTickets>0,"Can only organise event if no of ticket is more than 0");
        events[nextId]=Event(msg.sender,_name,_date,_prize,_noOfTickets,_noOfTickets);
        nextId++;
    }
    function buyTicket(uint Id,uint quantity) external payable
    {
        require(events[Id].date!=0,"Event does not exist");
        require(events[Id].date>block.timestamp,"Event already occured");
        Event storage MEvent = events[Id];
        require(msg.value==MEvent.prize*quantity,"Money paid is less");
        require(MEvent.TicketRemain>=quantity,"Not enough tickets left");
        MEvent.TicketRemain-=quantity;
        tickets[msg.sender][Id]+=quantity;

    }
    function TransferTicket(uint Id,uint quantity,address to) external
    {
        require(events[Id].date!=0,"Event does not exist");
        require(events[Id].date>block.timestamp,"Event already occured");
        require(tickets[msg.sender][Id]>=quantity,"you dont have enough tickets");
        tickets[msg.sender][Id]-=quantity;
        tickets[to][Id]+=quantity;
    }
}