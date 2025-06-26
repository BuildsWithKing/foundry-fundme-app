//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//1. limit self-triage to 15 / 20 minutes
//2. Don't be afraid to ask AI, but don't skip learning
//3. Use Forum to ask questions
//4. Google the Exact Errors
//5. Make post on stack Exchange or peeranha, Use Mark Downs ''' to format your code '''
//6. Make post on GitHub

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //ABI
        (, int256 price,,,) = priceFeed.latestRoundData();
        //Price of ETH in terms of USD
        //200000000
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // 1ETH?
        // (2000000000000000000 * 1000000000000000000) /1e18;
        // $2000 = 1ETH
        //msg.value.getConversionRate();
        uint256 ethPrice = getPrice(priceFeed);
        //1000000000000000000 * 1000000000000000000 =100000000000000000000000000000000000000
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF).version();
    }
}
