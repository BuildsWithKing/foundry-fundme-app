//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol"; //Importing the FundMe contract
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; //Importing the DeployFundMe script

contract FundMeUnitTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); //Creating a user address for testing using makeAddr function from forge-std
    uint256 constant ETH_AMOUNT = 0.1 ether; //Setting a constant ETH amount for testing, equivalent to 0.1 ETH
    uint256 constant STARTING_BALANCE = 10 ether; //Setting a constant starting balance for the user, equivalent to 10 ETH
    uint256 constant GAS_PRICE = 1; //Setting a constant gas price for testing, equivalent to 1 wei

    function setUp() external {
        //This is the setup function that runs before each test
        //It is used to initialize the contract and set up the environment
        DeployFundMe deployFundMe = new DeployFundMe(); //Creating a new instance of the FundMe contract
        fundMe = deployFundMe.run(); //Running the deployFundMe script to deploy the contract
        vm.deal(USER, STARTING_BALANCE); //This gives the USER address a starting balance of 10 ETH
    }

    function test_MinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); //This checks that the minimum USD is 5 USD
    }

    function test_OwnerIsMsgSender() public view {
        console.log("Contract Owner is : ", fundMe.getOwner());
        console.log("Message Sender is : ", address(this));
        //This checks that the owner of the contract is the message sender
        //When the contract is deployed, the deployer is the owner
        assertEq(fundMe.getOwner(), msg.sender); //This checks that the owner of the contract is the message sender
    }

    //Unit Test
    function test_PriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        //This checks that the price feed version is accurate
        //It compares the version of the price feed with the expected version
        assertEq(version, 4); //The expected return version is 4
    }

    //This test ensures that the fund function fails when not enough ETH is sent.
    function test_FundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //hey, the next line, should revert!
        fundMe.fund(); //sends 0 value
    }

    function test_FundUpdatesFundedDataStructure() public {
        vm.prank(USER); //This sets the next transaction to be sent from the USER address
        fundMe.fund{value: ETH_AMOUNT}(); //This sends 10 USD to the fund function

        uint256 amountFunded; // This variable will hold the amount funded by the message sender
        amountFunded = fundMe.getAddressToAmountFunded(USER); // This gets the amount funded by the USER address
        console.log("Amount Funded by USER: ", amountFunded);
        assertEq(amountFunded, ETH_AMOUNT); //This checks that the amount funded is equal to 0.1 ETH
    }

    function test_AddsFunderToArrayOfFunders() public {
        vm.prank(USER); //This sets the next transaction to be sent by the USER address
        fundMe.fund{value: ETH_AMOUNT}(); //This sends 0.1 ETH to the fund function
        address funder = fundMe.getFunderAddress(0); //This gets the address of the first funder
        assertEq(funder, USER); //This checks that the first funder is the USER address
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: ETH_AMOUNT}();
        _; //This modifier funds the contract with 0.1 ETH before executing the test function
    }

    function test_OnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); //This sets the next transaction to be sent by the USER address
        vm.expectRevert(); //This expects the next line to revert
        fundMe.withdraw(); //This tries to call the withdraw function from the USER address, which should fail since only the owner can withdraw
    }

    function test_WithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Starting balance of the FundMe Contract owner
        uint256 startingFundMeBalance = address(fundMe).balance; // Starting balance of the FundMe contract

        //Act, Here we are testing the withdraw function
        vm.prank(fundMe.getOwner()); //This sets the next transaction to be sent by the owner of the contract
        fundMe.withdraw(); //This calls the withdraw function for the owner's address

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; //This gets the ending balance of the Contract owner
        uint256 endingFundMeBalance = address(fundMe).balance; //This gets the ending balance of the FundMe contract
        assertEq(endingFundMeBalance, 0); //This checks that the ending balance of the FundMe contract is 0
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance); //This checks that the ending balance of the Contract owner is equal to the starting balance plus the starting balance of the FundMe contract
    }

    function test_WithdrawFromMultipleFunders() public funded {
        //Arrange phase
        //This is the arrange phase where we set up the test environment
        uint160 numberOfFunders = 10; //This sets the number of funders to 10
        uint160 startingFunderIndex = 1; //This sets the starting index for the funders to 1
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank
            //vm.deal creates a new address and gives it a balance
            //fund the fundMe contract
            hoax(address(i), ETH_AMOUNT); // Creates a blank address of i, which starts with 1 and adds ETH_AMOUNT to it
            fundMe.fund{value: ETH_AMOUNT}(); //This sends 0.1 ETH to the fund function from the new addresses
                // The many funders loops through the addresses from 1 to 10, and funds the contract with 0.1 ETH each time
        }
        //Act phase
        //This is the act phase where we call the withdraw function
        uint256 startingOwnerBalance = fundMe.getOwner().balance; //This gets the starting balance of the Contract owner
        uint256 startingFundMeBalance = address(fundMe).balance; //This gets the starting balance of the FundMe contract
        vm.startPrank(fundMe.getOwner()); //This sets the next transaction to be sent by the owner of the contract
        fundMe.withdraw(); //This calls the withdraw function for the owner's address
        vm.stopPrank(); //This stops the prank, so the next transaction will be sent by the message sender

        //Assert phase
        //This is the assert phase where we check the results of the test
        assert(address(fundMe).balance == 0); //This checks that the ending balance of the FundMe contract is 0
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); //This checks that the ending balance of the Contract owner is equal to the starting balance plus the starting balance of the FundMe contract
    }

    function test_WithdrawCheaperFromMultipleFunders() public funded {
        //Arrange phase
        //This is the arrange phase where we set up the test environment
        uint160 numberOfFunders = 10; //This sets the number of funders to 10
        uint160 startingFunderIndex = 1; //This sets the starting index for the funders to 1
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank
            //vm.deal creates a new address and gives it a balance
            //fund the fundMe contract
            hoax(address(i), ETH_AMOUNT); // Creates a blank address of i, which starts with 1 and adds ETH_AMOUNT to it
            fundMe.fund{value: ETH_AMOUNT}(); //This sends 0.1 ETH to the fund function from the new addresses
                // The many funders loops through the addresses from 1 to 10, and funds the contract with 0.1 ETH each time
        }
        //Act phase
        //This is the act phase where we call the withdraw function
        uint256 startingOwnerBalance = fundMe.getOwner().balance; //This gets the starting balance of the Contract owner
        uint256 startingFundMeBalance = address(fundMe).balance; //This gets the starting balance of the FundMe contract
        vm.startPrank(fundMe.getOwner()); //This sets the next transaction to be sent by the owner of the contract
        fundMe.cheaperWithdraw(); //This calls the withdraw function for the owner's address
        vm.stopPrank(); //This stops the prank, so the next transaction will be sent by the message sender

        //Assert phase
        //This is the assert phase where we check the results of the test
        assertEq(address(fundMe).balance, 0); //This checks that the ending balance of the FundMe contract is 0
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance); //This checks that the ending balance of the Contract owner is equal to the starting balance plus the starting balance of the FundMe contract
    }

    function test_UserCanFundMultipleTimes() public funded {
        //This function tests if user can fund multiple times
        vm.prank(USER); ////This sets the next transaction to be sent by the USER address
        fundMe.fund{value: ETH_AMOUNT}(); //This sends 0.1 ETH to the fund function
        assertEq(fundMe.getAddressToAmountFunded(USER), ETH_AMOUNT * 2); //This ensures that fund sent by the user is equal to ETH_AMOUNT multiply by 2
    }
}
