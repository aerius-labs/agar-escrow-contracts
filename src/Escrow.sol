//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NftEscrow is IERC721Receiver {
    enum EscrAvailable {
        NO,
        YES
    }

    address payable public escrAddress;
    address payable public playerAddress;
    address public nftAddress;
    uint256 tokenId;

    mapping(address => address) nftOf; // this will map the players to their NFT address
    EscrAvailable public escrAvailable;

    constructor() {
        escrAddress = payable(address(this));
        escrAvailable = EscrAvailable.YES;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        public
        override
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
    // This will be a function to deposit NFTS of all the players and send it to this smart contract address //

    function depositNFT(address _NFTAddress, uint256 _TokenID) public inEscrAvailable(EscrAvailable.YES) onlyPlayer {
        nftAddress = _NFTAddress;
        playerAddress = payable(msg.sender);
        tokenId = _TokenID;
        ERC721(nftAddress).safeTransferFrom(msg.sender, address(this), tokenId);
        nftOf[playerAddress] = nftAddress;
    }

    function viewOriginalNftOfPlayer(address _PlayerAddress) public view returns (address) {
        require(_PlayerAddress != address(0), "Address should not be the zero address");
        return nftOf[_PlayerAddress];
    }
    // modifer such that only Player can perform action //

    modifier onlyPlayer() {
        require(msg.sender != escrAddress);
        _;
    }
    // modifier to check if the escrow is available or not //

    modifier inEscrAvailable(EscrAvailable _state) {
        require(escrAvailable == _state);
        _;
    }
}
