//SPDX-License-Identifier: MIT
//1. Deploy mocks when we are on a local anvil chain
//2. Keep track of contracts addresses across different chains
//Sepolia ETH/USD price feed address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
//Mainnet ETH/USD price feed address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol"; //Importing the MockV3Aggregator contract

contract HelperConfig is Script {
    //if we are on a local anvil chain, we will deploy mocks
    //otherwise, grab the existing addresses from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8; //Number of decimals for the price feed
    int256 public constant INITIAL_PRICE = 2000e8; //Initial price for the price feed (2000 USD with 8 decimals)
    uint256 public constant SEPOLIAETH_ID = 11155111; //Sepolia network chain ID
    uint256 public constant ETH_MAINNET_ID = 1; //Ethereum Mainnet chain ID

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == SEPOLIAETH_ID) {
            //Sepolia network
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == ETH_MAINNET_ID) {
            //Ethereum Main network
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            //Anvil Network
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //This function returns the configuration for the Sepolia network
        //It is used to get the price feed address and the deployer address for the Sepolia network
        //price feed address:
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //This function returns the configuration for the Ethereum Mainnet network
        //It is used to get the price feed address and the deployer address for the Ethereum Main network
        //price feed address:
        NetworkConfig memory ethMainnetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethMainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (
            activeNetworkConfig.priceFeed != address(0) //This is a way to get the zero address or the default value of the address type
        ) {
            return activeNetworkConfig;
        } //If the price feed address is already set, return the existing configuration
        //This function returns the configuration for the Anvil network
        //It is used to get the price feed address and the deployer address for the Anvil network
        //price feed address:
        //1. Deploys the mock
        //2. Returns the mock addresses

        vm.startBroadcast(); //Starting the broadcast of the transaction and Creating a new instance of the MockV3Aggregator contract
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); //8 decimals, initial price of 2000 USD

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        activeNetworkConfig = anvilConfig;
        return anvilConfig;
    }
}
