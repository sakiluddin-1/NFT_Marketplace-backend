// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/BasicNFT.sol";
import "../src/NFTMarketplace.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BasicNFT basicNFT = new BasicNFT(10000, "");

        NftMarketplace marketplace = new NftMarketplace();

        vm.stopBroadcast();

        console.log("BasicNFT deployed at:", address(basicNFT));
        console.log("Marketplace deployed at:", address(marketplace));
    }
}
