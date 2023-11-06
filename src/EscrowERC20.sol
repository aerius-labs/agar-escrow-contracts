// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EscrowERC20 {
    /**
     * All Errors
     */
    error EscrowERC20__TransferFailed(address from, address to, uint256 amount);
    error EscrowERC20__OnlyPlayerAllowed();
    error EscrowERC20__EscrowNotAvailable();
    error EscrowERC20__AddressMustBeNotZero();
    error EscrowERC721__OnlyAdminAllowed();
    error EscrowERC20__PlayerContractDoNotHaveTokensTransfered();

    /**
     * All enums
     */
    enum EscrERC20Available {
        NO,
        YES
    }
    /**
     * All state variables
     */

    address public escrAddress;
    address public playerAddress;
    address public contractAddress;
    address public adminAddress = 0x4cd4df5E4485ffd09345bB5dAC0fcE06Dd00ef07;
    uint256 public totalBalance;

    EscrERC20Available public escrAvailable;
    mapping(address => mapping(address => uint256)) playerToContractToAmount;
    mapping(address => address[]) playerToContracts;

    constructor() {
        escrAddress = address(this);
        escrAvailable = EscrERC20Available.YES;
    }

    function depositTokens(address _ContractAddress, uint256 _Amount)
        public
        inEscrAvailable(EscrERC20Available.YES)
        onlyPlayer
    {
        playerAddress = msg.sender;
        contractAddress = _ContractAddress;
        bool success = ERC20(_ContractAddress).transferFrom(msg.sender, address(this), _Amount);
        if (!success) revert EscrowERC20__TransferFailed(msg.sender, address(this), _Amount);
        totalBalance += _Amount;
        playerToContracts[playerAddress].push(contractAddress);
        playerToContractToAmount[playerAddress][contractAddress] = _Amount;
    }

    function transferTokens(address _PlayerAddress, address _ContractAddress, uint256 _Amount)
        public
        inEscrAvailable(EscrERC20Available.YES)
        onlyAdmin
    {
        playerAddress = _PlayerAddress;
        contractAddress = _ContractAddress;
        bool success = ERC20(contractAddress).transfer(playerAddress, _Amount);
        if (!success) revert EscrowERC20__TransferFailed(address(this), playerAddress, _Amount);
        totalBalance -= _Amount;
    }

    /**
     * All modifiers
     */
    modifier onlyPlayer() {
        if (msg.sender == escrAddress) {
            revert EscrowERC20__OnlyPlayerAllowed();
        }
        _;
    }

    modifier inEscrAvailable(EscrERC20Available _state) {
        if (escrAvailable != _state) {
            revert EscrowERC20__EscrowNotAvailable();
        }
        _;
    }

    modifier onlyAdmin() {
        if (msg.sender != adminAddress) {
            revert EscrowERC721__OnlyAdminAllowed();
        }
        _;
    }

    /**
     * View functions
     */
    function viewAllOriginalContractAddressOfPlayer(address _PlayerAddress) public view returns (address[] memory) {
        if (_PlayerAddress == address(0)) {
            revert EscrowERC20__AddressMustBeNotZero();
        }
        return playerToContracts[playerAddress];
    }

    function viewOriginalTokensThatPlayerSendToEscrow(address _PlayerAddress, address _ContractAddress)
        public
        view
        returns (uint256)
    {
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

    function updateTotalBalance(uint256 newBalance) public {
        totalBalance = newBalance;
    }
}
