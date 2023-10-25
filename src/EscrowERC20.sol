// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EscrowERC20 {

    error EscrowERC20__TransferFailed(address from, address to, uint256 amount);
    error EscrowERC20__OnlyPlayerAllowed();
    error EscrowERC20__EscrowNotAvailable();
    
    
    enum EscrERC20Available {
        NO,
        YES
    }

    address public escrAddress;
    address public playerAddress;
    address public contractAddress;

    uint256 public totalBalance;

    EscrERC20Available public escrAvailable;

    mapping(address => mapping(address => uint256)) playerToContractToAmount;


    constructor() {
        escrAddress = address(this);
        escrAvailable = EscrERC20Available.YES;
    }

    function depositTokens(address _ContractAddress, uint256 _Amount) public inEscrAvailable(EscrERC20Available.YES) onlyPlayer {
        playerAddress = msg.sender;
        contractAddress = _ContractAddress;
        bool success = ERC20(_ContractAddress).transferFrom(msg.sender,address(this),_Amount);
        if(!success) revert EscrowERC20__TransferFailed(msg.sender, address(this),_Amount);
        totalBalance += _Amount;
        playerToContractToAmount[playerAddress][contractAddress] = _Amount;
    }

    modifier onlyPlayer() {
        if(msg.sender == escrAddress){
            revert EscrowERC20__OnlyPlayerAllowed();
        }
        _;
    }

    modifier inEscrAvailable(EscrERC20Available _state) {
        if(escrAvailable != _state){
            revert EscrowERC20__EscrowNotAvailable();
        }
        _;
    }

}