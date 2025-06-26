//SPDX-License-Identifier: MIT

//FUND SCRIPT
//WITHDRAW SCRIPT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant ETH_AMOUNT = 0.01 ether; // Amount to fund in Ether

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // Start broadcasting the transaction
        FundMe(payable(mostRecentlyDeployed)).fund{value: ETH_AMOUNT}(); // Call the fund function with the specified amount
        // The payable keyword allows the contract to receive Ether
        console.log("Funded FundMe with %s", ETH_AMOUNT); // Logs the funding action on the console
        vm.stopBroadcast(); // Stop broadcasting the transaction
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // Start broadcasting the transaction
        FundMe(payable(mostRecentlyDeployed)).withdraw(); // Call the withdraw function
        vm.stopBroadcast(); // Stop broadcasting the transaction
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "fundMe",
            block.chainid
        );

        withdrawFundMe(mostRecentlyDeployed);
    }
}
