// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//772,233 gas
// 751,865 gas After adding the constant Keyword
//constant, Immutable keyword
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner(); //Custom Error, Outside of the Contract

contract FundMe {
    using PriceConverter for uint256;

    //347 - Constant
    //2446 - Without constant keyword

    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded; // s_ is a common prefix for state variables (shows we are reading from storage)
    address[] private s_funders; // Array to keep track of funders

    address private immutable i_owner; //    //Immutable variables are set once in the constructor and cannot be changed later
    //Immutable variables are cheaper to use than regular state variables
    uint256 public constant MINIMUM_USD = 5 * 1e18; // 1 * 10 ** 18
    AggregatorV3Interface private s_priceFeed; //State Variable

    constructor(address priceFeed) {
        i_owner = msg.sender;
        //439 gas - immutable
        //2574 gas - Non-immutable
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        /**
         * Allow users to send $
         * Have a minimum $ sent $5
         * 1. How do we send ETH to this contract ?
         *
         */
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You Didn't Send Enough ETH"); // Checks if the sent ETH is above the minimum USD threshold
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length; // Storing the length of the funders array in a variable to save gas
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0; // Resetting the amount
        }

        s_funders = new address[](0); //resetting the Array to save gas
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function withdraw() public onlyOwner {
        //for loop
        //1,2,3,4] elements
        //[0,1,2,3] indexes
        //for (/* starting index, ending index, step amount*/)
        // 0,10, 1
        //funder++ adds one everytime the compiler gos through the loop
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0); //resetting the Array
        // after the funds are withdrawn

        // transfer
        //send
        //call

        //msg.sender = address
        //payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);
        // Send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require (sendSuccess, "Failed to Send ETH To Funder");

        //call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        // require(msg.sender ==i_owner, "Sender is not Owner");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    //  What happens if someone sends this contract ETH without calling the fund function?

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure Functions (Getters)
     */
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        // This function returns the amount funded by a specific address
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunderAddress(uint256 index) external view returns (address) {
        // This function returns the address of a funder at a specific index
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        // This function returns the owner of the contract
        return i_owner;
    }
}
