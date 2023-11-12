//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NftEscrow is IERC721Receiver, ReentrancyGuard {
    /**
     * All Errors
     */
    error EscrowERC721__EscrowNotAvailable();
    error EscrowERC721__AddressMustBeNotZero();
    error EscrowERC721__OnlyAdminAllowed();

    /**
     * All state variables
     */

    address public adminAddress;

    bool public escrAvailable;
    mapping(address => address[]) nftOfs; // this will map the players to their NFT(contract) address
    mapping(address => mapping(address => uint256)) playerToNftAddressToTokenId;

    constructor(address _AdminAddress) {
        adminAddress = _AdminAddress;
        escrAvailable = true;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // This will be a function to deposit NFTS of all the players and send it to this smart contract address //

    function depositNFT(
        address _NFTAddress,
        uint256 _TokenID
    ) external nonReentrant {
        if (escrAvailable == false) revert EscrowERC721__EscrowNotAvailable();
        nftOfs[msg.sender].push(_NFTAddress);
        playerToNftAddressToTokenId[msg.sender][_NFTAddress] = _TokenID;
        ERC721(_NFTAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _TokenID
        );
    }

    function transferNFT(
        address _PlayerAddress,
        address _NFTAdddres,
        uint256 _TokenID
    ) external onlyAdmin nonReentrant {
        if (escrAvailable == false) revert EscrowERC721__EscrowNotAvailable();
        ERC721(_NFTAdddres).safeTransferFrom(
            address(this),
            _PlayerAddress,
            _TokenID
        );
    }

    /**
     * All modifiers
     */

    modifier onlyAdmin() {
        if (msg.sender != adminAddress) {
            revert EscrowERC721__OnlyAdminAllowed();
        }
        _;
    }

    /**
     * View functions
     */

    function viewOriginalNftsOfPlayer(
        address _PlayerAddress
    ) external view returns (address[] memory) {
        if (_PlayerAddress == address(0)) {
            revert EscrowERC721__AddressMustBeNotZero();
        }
        return nftOfs[_PlayerAddress];
    }

    function viewOriginalNftTokensThatPlayerSendToEscrow(
        address _PlayerAddress,
        address _NFTAddress
    ) external view returns (uint256) {
        if (_PlayerAddress == address(0)) {
            revert EscrowERC721__AddressMustBeNotZero();
        }
        if (_NFTAddress == address(0)) {
            revert EscrowERC721__AddressMustBeNotZero();
        }
        return playerToNftAddressToTokenId[_PlayerAddress][_NFTAddress];
    }
}
