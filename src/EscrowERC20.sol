// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract EscrowERC20 is ReentrancyGuard {
    /**
     * All Errors
     */
    error EscrowERC20__TransferFailed(address from, address to, uint256 amount);
    error EscrowERC20__EscrowNotAvailable();
    error EscrowERC20__AddressMustBeNotZero();
    error EscrowERC721__OnlyAdminAllowed();
    error EscrowERC20__PlayerContractDoNotHaveTokensTransfered();

    /**
     * All state variables
     */

    address public adminAddress;
    uint256 public totalBalance;

    bool public escrAvailable;
    mapping(address => mapping(address => uint256)) playerToContractToAmount;
    mapping(address => address[]) playerToContracts;

    constructor(address _AdminAddress) {
        adminAddress = _AdminAddress;
        escrAvailable = true;
    }

    function depositTokens(
        address _ContractAddress,
        uint256 _Amount
    ) external nonReentrant {
        if (escrAvailable == false) revert EscrowERC20__EscrowNotAvailable();
        totalBalance += _Amount;
        playerToContracts[msg.sender].push(_ContractAddress);
        playerToContractToAmount[msg.sender][_ContractAddress] = _Amount;
        bool success = ERC20(_ContractAddress).transferFrom(
            msg.sender,
            address(this),
            _Amount
        );
        if (!success)
            revert EscrowERC20__TransferFailed(
                msg.sender,
                address(this),
                _Amount
            );
    }

    function transferTokens(
        address _PlayerAddress,
        address _ContractAddress,
        uint256 _Amount
    ) external onlyAdmin nonReentrant {
        if (escrAvailable == false) revert EscrowERC20__EscrowNotAvailable();
        totalBalance -= _Amount;
        bool success = ERC20(_ContractAddress).transfer(
            _PlayerAddress,
            _Amount
        );
        if (!success)
            revert EscrowERC20__TransferFailed(
                address(this),
                _PlayerAddress,
                _Amount
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
    function viewAllOriginalContractAddressOfPlayer(
        address _PlayerAddress
    ) external view returns (address[] memory) {
        if (_PlayerAddress == address(0)) {
            revert EscrowERC20__AddressMustBeNotZero();
        }
        return playerToContracts[_PlayerAddress];
    }

    function viewOriginalTokensThatPlayerSendToEscrow(
        address _PlayerAddress,
        address _ContractAddress
    ) external view returns (uint256) {
        if (_PlayerAddress == address(0)) {
            revert EscrowERC20__AddressMustBeNotZero();
        }
        if (_ContractAddress == address(0)) {
            revert EscrowERC20__AddressMustBeNotZero();
        }
        if (playerToContractToAmount[_PlayerAddress][_ContractAddress] == 0) {
            revert EscrowERC20__PlayerContractDoNotHaveTokensTransfered();
        }
        return playerToContractToAmount[_PlayerAddress][_ContractAddress];
    }

    // this function is only used for testing to avoid interger underflow whenever we transfer balance goes negative //
    function updateTotalBalance(uint256 newBalance) external {
        totalBalance = newBalance;
    }
}
