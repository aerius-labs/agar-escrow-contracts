//SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract nftescrow is IERC721Receiver {
    
    enum PlayerState {newEscrow, nftDeposited, cancelNFT, canceledBeforeDelivery, deliveryInitiated, delivered}         // player state
    
    address payable public sellerAddress;
    address payable public buyerAddress;
    address public nftAddress;
    uint256 tokenID;
    PlayerState public playerState;

    constructor()
    {
        sellerAddress = payable(msg.sender);
        playerState = PlayerState.newEscrow;
    }
    // It must return its Solidity selector to confirm the token transfer. If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    // This will be a function to deposit NFTS of all the players and send it to this smart contract address //
    function depositNFT(address _NFTAddress, uint256 _TokenID)
        public
        inPlayerState(PlayerState.newEscrow)
        onlySeller
    {
        nftAddress = _NFTAddress;
        tokenID = _TokenID;
        // ERC721(nftAddress) is attempting to interact with an ERC-721 token contract. It uses the nftAddress variable, which is assumed to hold the address of the ERC-721 token contract
        ERC721(nftAddress).safeTransferFrom(msg.sender, address(this), tokenID);        
        playerState = PlayerState.nftDeposited;
    }
    // modifer such that only seller can perform action
	modifier onlySeller() {
		require(msg.sender == sellerAddress);
		_;
	}
	// modifier which checks the player state
	modifier inPlayerState(PlayerState _state) {
		require(playerState == _state);
		_;
	}
} 