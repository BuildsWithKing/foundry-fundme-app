//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol"; //Importing the FundMe contract
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; //Importing the DeployFundMe script
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol"; //Importing the interaction script for funding and withdrawing

contract FundMeIntegrationTest is Test {
    FundMe fundMe; //Declaring a variable of type FundMe to hold the deployed contract instance

    address USER = makeAddr("user"); //Creating a user address for testing using makeAddr function from forge-std
    uint256 constant ETH_AMOUNT = 0.1 ether; //Setting a constant ETH amount for testing, equivalent to 0.1 ETH
    uint256 constant STARTING_BALANCE = 10 ether; //Setting a constant starting balance for the user, equivalent to 10 ETH
    uint256 constant GAS_PRICE = 1; //Setting a constant gas price for testing, equivalent to 1 wei

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe(); //Creating a new instance of the DeployFundMe script
        fundMe = deploy.run(); //Running the deploy script to deploy the contract
        vm.deal(USER, STARTING_BALANCE); //This gives the USER address a starting balance of 10 ETH
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe(); //Creating a new instance of the FundFundMe script
        fundFundMe.fundFundMe(address(fundMe)); // This calls the fundFundMe function on the FundMe contract

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe(); //Creating a new instance of the WithdrawFundMe script
        withdrawFundMe.withdrawFundMe(address(fundMe)); // This calls the withdrawFundMe function on the FundMe contract

        assert(address(fundMe).balance == 0); //This checks that the balance of the FundMe contract is 0 after withdrawal
    }
}
// This integration test checks if the user can fund the FundMe contract and then withdraw the funds successfully.
// It uses the FundFundMe and WithdrawFundMe scripts to perform the funding and withdrawal actions
// and asserts that the balance of the FundMe contract is 0 after the withdrawal.
// The test is set up with a user address that has a starting balance of 10 ETH
