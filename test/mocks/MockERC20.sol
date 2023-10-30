// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    uint256 public _TotalSupply;

    constructor(uint256 initialSupply) ERC20("Mock ERC20", "MRC") {
        _TotalSupply = initialSupply * 10 ** decimals();
    }

    // function to send some specific amount of tokens to address to //
    function mint(address to, uint256 amount) external {
        super._mint(to, amount * 10 ** decimals());
    }
}
