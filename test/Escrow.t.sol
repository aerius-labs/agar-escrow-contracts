// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NftEscrow} from "../src/Escrow.sol";
import "./mocks/MockERC721.sol";

contract NftEscrowTest is Test {
    NftEscrow public nftEscrow;
    MockERC721 public mockERC721;

    // intializing the ecrow contract and MockERC721 //

    function setUp() public {
        nftEscrow = new NftEscrow();
        mockERC721 = new MockERC721();
    }

    // function to test the Escrow state //

    function testInitialEscrowAvailable() public {
        NftEscrow.EscrAvailable expected = NftEscrow.EscrAvailable.YES;
        NftEscrow.EscrAvailable actual = nftEscrow.escrAvailable();
        assertEq(uint256(expected), uint256(actual), "Escrow should be available initially.");
    }

    // function to test the deposit of the tokens //

    function testDepositTokens() public {
        // creating Players //
        address player1Nft = address(1);
        address player2Nft = address(2);

        // mint a new token to these players and approve it to the escrow contract //
        uint256 tokenId = 1;
        mockERC721.mint(player1Nft, tokenId);
        vm.prank(player1Nft);
        mockERC721.approve(address(nftEscrow), tokenId);

        // Perfomring the transfer //
        // before making the msg.sender to player1
        vm.prank(player1Nft);
        nftEscrow.depositNFT(address(mockERC721), 1);

        // Checking if the deposit was successful
        address originalNft = nftEscrow.viewOriginalNftOfPlayer(player1Nft);
        assertEq(address(mockERC721), originalNft, "NFT deposit was not successful.");
    }
}
