// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NftEscrow} from "../src/EscrowERC721.sol";
import "./mocks/MockERC721.sol";

contract NftEscrowTest is Test {
    NftEscrow public nftEscrow;
    MockERC721 public mockERC721;
    address public adminAddress = 0x4cd4df5E4485ffd09345bB5dAC0fcE06Dd00ef07;

    // intializing the ecrow contract and MockERC721 //

    function setUp() public {
        nftEscrow = new NftEscrow();
        mockERC721 = new MockERC721();
    }

    // function to test the Escrow state //

    function testInitialEscrowAvailable() public {
        bool expected = true;
        bool actual = nftEscrow.escrAvailable();
        assertEq(expected, actual, "Escrow should be available initially.");
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
        address currentOwnerOfNft = mockERC721.ownerOf(tokenId);
        assertEq(
            address(nftEscrow),
            currentOwnerOfNft,
            "NFT deposit was not successful."
        );
    }

    // writing fuzz test so to test it on multiple inputs //

    function testFuzzDepositNftTokens(
        string memory playerAddress,
        uint256 tokenId
    ) public {
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
        address currentOwnerOfNft = mockERC721.ownerOf(tokenId);
        assertEq(
            address(nftEscrow),
            currentOwnerOfNft,
            "NFT deposit was not successful."
        );
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

    function testFuzzTransferNftFromEscrow(
        string memory playerAddress,
        uint256 tokenId
    ) public {
        // creating players
        address player = address(bytes20(bytes(playerAddress)));
        vm.assume(player != address(0));
        // minting tokens to Escrow for testing //
        mockERC721.mint(address(nftEscrow), tokenId);
        // calling from admin so that only admin can perform transfer //
        vm.prank(address(adminAddress));
        nftEscrow.transferNFT(player, address(mockERC721), tokenId);
        // checking the current owner of that token matches our player //
        address currentOwnerOfNft = mockERC721.ownerOf(tokenId);
        assertEq(player, currentOwnerOfNft, "NFT Transfer was not successful.");
    }

    function testFailFuzzEscrowDoesNotHaveOwnership(
        string memory playerAddress,
        uint256 tokenId
    ) public {
        // creating Players and assigning tokens //
        address player = address(bytes20(bytes(playerAddress)));
        vm.assume(player != address(0));

        // checking the ownership //
        address owner = mockERC721.ownerOf(tokenId);
        assertEq(owner, address(nftEscrow), "owner Test");
    }
}
