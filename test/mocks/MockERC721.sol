// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("Mock ERC721", "MERC") {}

    // function to mint tokens //
    function mint(address to, uint256 tokenId) external {
        super._mint(to, tokenId);
    }

    // function to approve the tranfer of tokens //
    function approve(address to, uint256 tokenId) public override {
        super.approve(to, tokenId);
    }
}
