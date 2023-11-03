//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NftEscrow is IERC721Receiver {
    /**
     * All Errors
     */
    error EscrowERC721__OnlyPlayerAllowed();
    error EscrowERC721__EscrowNotAvailable();
    error EscrowERC721__AddressMustBeNotZero();
    error EscrowERC721__OnlyEscrowAllowed();

    /**
     * All enums
     */
    enum EscrAvailable {
        NO,
        YES
    }
    /**
     * All state variables
     */

    address payable public escrAddress;
    address payable public playerAddress;
    address public nftAddress;
    uint256 tokenID;

    EscrAvailable public escrAvailable;
    mapping(address => address[]) nftOfs; // this will map the players to their NFT(contract) address
    mapping(address => mapping(address => uint256)) playerToNftAddressToTokenId;

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
        tokenID = _TokenID;
        ERC721(nftAddress).safeTransferFrom(msg.sender, address(this), tokenID);
        nftOfs[playerAddress].push(nftAddress);
        playerToNftAddressToTokenId[playerAddress][nftAddress] = tokenID;
    }

    function transferNFT(address _PlayerAddress, address _NFTAdddres, uint256 _TokenID)
        public
        inEscrAvailable(EscrAvailable.YES)
        onlyEscrow
    {
        nftAddress = _NFTAdddres;
        playerAddress = payable(_PlayerAddress);
        tokenID = _TokenID;
        ERC721(nftAddress).approve(playerAddress,tokenID);
        ERC721(nftAddress).safeTransferFrom(address(this), playerAddress, tokenID);
    }

    /**
     * All modifiers
     */

    modifier onlyPlayer() {
        if (msg.sender == escrAddress) {
            revert EscrowERC721__OnlyPlayerAllowed();
        }
        _;
    }

    modifier onlyEscrow() {
        if (msg.sender != escrAddress) {
            revert EscrowERC721__OnlyEscrowAllowed();
        }
        _;
    }
    // modifier to check if the escrow is available or not //

    modifier inEscrAvailable(EscrAvailable _state) {
        if (escrAvailable != _state) {
            revert EscrowERC721__EscrowNotAvailable();
        }
        _;
    }

    /**
     * View functions
     */

    function viewOriginalNftsOfPlayer(address _PlayerAddress) public view returns (address[] memory) {
        if (_PlayerAddress == address(0)) {
            revert EscrowERC721__AddressMustBeNotZero();
        }
        return nftOfs[_PlayerAddress];
    }

    function viewOriginalNftTokensThatPlayerSendToEscrow(address _PlayerAddress, address _NFTAddress)
        public
        view
        returns (uint256)
    {
        if (_PlayerAddress == address(0)) {
            revert EscrowERC721__AddressMustBeNotZero();
        }
        if (_NFTAddress == address(0)) {
            revert EscrowERC721__AddressMustBeNotZero();
        }
        return playerToNftAddressToTokenId[_PlayerAddress][_NFTAddress];
    }
}
