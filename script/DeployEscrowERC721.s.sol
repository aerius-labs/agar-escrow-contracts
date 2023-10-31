// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NftEscrow} from "../src/EscrowERC721.sol";

contract DeployEscrowERC721 is Script {

    function run() public returns(NftEscrow) {
        vm.startBroadcast();
        NftEscrow nftEscrow = new NftEscrow();
        vm.stopBroadcast();
        return nftEscrow;
    }
}
