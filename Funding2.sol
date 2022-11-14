// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./EthereumConverter.sol";

error NotOwner();
error CallFailed();
error NotEnough();

contract Funding2 {
    using EthereumConverter for uint256;

    mapping(address => uint256) public addressToFunder;
    address[] public funders;
    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
       if (msg.value.getConversionRate() >= MINIMUM_USD) 
        {
          addressToFunder[msg.sender] += msg.value;
          funders.push(msg.sender);
          }
          else
          { revert NotEnough();}
    }
    
    modifier onlyOwner {
        if (msg.sender != i_owner) { revert NotOwner(); }
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToFunder[funder] = 0;
        }
        funders = new address[](0);
    
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
          if (callSuccess != true) { revert CallFailed(); }
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}
