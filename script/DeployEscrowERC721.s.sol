// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NftEscrow} from "../src/EscrowERC721.sol";

contract DeployEscrowERC721 is Script {
    address public adminAddress = 0x4cd4df5E4485ffd09345bB5dAC0fcE06Dd00ef07;

    function run() public returns (NftEscrow) {
        vm.startBroadcast();
        NftEscrow nftEscrow = new NftEscrow(adminAddress);
        vm.stopBroadcast();
        return nftEscrow;
    }
}
