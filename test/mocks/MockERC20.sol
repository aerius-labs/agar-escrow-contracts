// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock ERC20", "MRC") {}

    // function to send some specific amount of tokens to address to //
    function mint(address to, uint256 amount) external {
        super._mint(to, amount * 10 ** decimals());
    }
}
