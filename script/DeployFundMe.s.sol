//SPDX-License-Identifier: MIT
//This is the script that deploys the FundMe contract

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol"; //Importing the HelperConfig contract

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //It is used to deploy the contract to the network
        //Before startBroadcast --> Not a "real" transaction
        HelperConfig helperConfig = new HelperConfig(); //Creating a new instance of the HelperConfig contract
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        vm.startBroadcast(); // starting the broadcast of the transaction
        //After startBroadcast --> A "real" transaction
        //This is the function that runs when the script is executed
        FundMe fundMe = new FundMe(ethUsdPriceFeed); //creating a new instance of the FundMe contract, which takes the price feed address as a parameter
        vm.stopBroadcast(); // stopping the broadcast of the transaction
        return fundMe;
    }
}
