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

    function testDepositNftTokens() public {
        // creating Players //
        address player1Nft = address(1);

        // mint a new token to these players and approve it to the escrow contract //
        uint256 tokenId = 1;
        mockERC721.mint(player1Nft, tokenId);
        // Before making the approve //
        // changing msg.sender to player1Nft so that token owner can approve //
        vm.prank(player1Nft);
        mockERC721.approve(address(nftEscrow), tokenId);

        // Perfomring the transfer //
        // before making the msg.sender to player1
        vm.prank(player1Nft);
        nftEscrow.depositNFT(address(mockERC721), tokenId);

        // Checking if the deposit was successful
        address originalNft = nftEscrow.viewOriginalNftOfPlayer(player1Nft);
        assertEq(address(mockERC721), originalNft, "NFT deposit was not successful.");
    }

    // writing fuzz test so to test it on multiple inputs //

    function testFuzzDepositNftTokens(string memory playerAddress, uint256 tokenId) public {
        // creating Players //
        address player = address(bytes20(bytes(playerAddress)));
        vm.assume(player != address(0)); // assume that player must not be zero address //

        // mint a new token to these players and approve it to the escrow contract //
        mockERC721.mint(player, tokenId);
        // Before making the approve //
        // changing msg.sender to player so that token owner can approve //
        vm.prank(player);
        mockERC721.approve(address(nftEscrow), tokenId);

        // Perfomring the transfer //
        // before making the msg.sender to player
        vm.prank(player);
        nftEscrow.depositNFT(address(mockERC721), tokenId);

        // Checking if the deposit was successful
        address originalNft = nftEscrow.viewOriginalNftOfPlayer(player);
        assertEq(address(mockERC721), originalNft, "NFT deposit was not successful.");
    }

    // writing a failure test if player who does not have token or not approved //
    function testFailPlayerDoesNotHaveApprovedOrOwner() public {
        // creating Players and assigning tokens //
        address player = address(1);
        uint256 tokenId = 1;

        // Checking owner and approved owner of tokenId //
        address originalPlayer = mockERC721.ownerOf(tokenId);
        address approvalAddress = mockERC721.getApproved(tokenId);

        // checking if they fails the test or not //
        assertEq(originalPlayer, player, "Owner test");
        assertEq(approvalAddress, address(nftEscrow), "Approval Test");
    }
}
