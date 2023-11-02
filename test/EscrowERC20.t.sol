// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EscrowERC20} from "../src/EscrowERC20.sol";
import "./mocks/MockERC20.sol";

contract EscrowERC20Test is Test {
    EscrowERC20 public escrowERC20;
    MockERC20 public mockERC20;
    uint256 totalSupply = 1000000 * (10 ** 18);

    function setUp() public {
        escrowERC20 = new EscrowERC20();
        mockERC20 = new MockERC20();
    }
    // function to test the Escrow state //

    function testInitialEscrowERC20Available() public {
        EscrowERC20.EscrERC20Available expected = EscrowERC20.EscrERC20Available.YES;
        EscrowERC20.EscrERC20Available actual = escrowERC20.escrAvailable();
        assertEq(uint256(expected), uint256(actual), "Escrow should be available initially.");
    }
    // function to test the deposit of the tokens //

    function testDepositERC20Tokens() public {
        // creating players //
        address player1 = address(1);

        // amount of tokens that want to send //
        uint256 amount = 100; // amount must not be zero //
        mockERC20.mint(player1, amount);

        // now we have to approve reciever to transfer amount from sender
        vm.prank(player1);
        bool success = mockERC20.approve(address(escrowERC20), amount);
        assertTrue(success, "ERC20: Approval failed");

        vm.prank(player1);
        escrowERC20.depositTokens(address(mockERC20), amount);

        uint256 recieveAmount = escrowERC20.viewOriginalTokensThatPlayerSendToEscrow(player1, address(mockERC20));
        assertEq(amount, recieveAmount, "ERC20:Recieve tokens failes");
    }
    // writing fuzz test so to test it on multiple inputs //

    function testFuzzDepositERC20Tokens(string memory playerAddress, uint256 amount) public {
        // creating Players //
        address player = address(bytes20(bytes(playerAddress)));
        vm.assume(player != address(0)); // assume that player must not be zero address //
        vm.assume(amount > 0);
        vm.assume(amount <= totalSupply);

        // mint a new token to these players and approve it to the escrow contract //
        mockERC20.mint(player, amount);
        amount = amount * (10 ** mockERC20.decimals()); // converting the amount into wei //

        // Before making the approve //
        // changing msg.sender to player so that token owner can approve //
        vm.prank(player);
        bool success = mockERC20.approve(address(escrowERC20), amount);
        assertTrue(success, "ERC20: Approval failed");

        // Perfomring the transfer //
        // before making the msg.sender to player
        vm.prank(player);
        escrowERC20.depositTokens(address(mockERC20), amount);

        // Checking if the deposit was successful
        uint256 recieveAmount = escrowERC20.viewOriginalTokensThatPlayerSendToEscrow(player, address(mockERC20));
        assertEqDecimal(amount, recieveAmount, mockERC20.decimals(), "ERC20:Recieve tokens failes");
    }
    // function to test if playerhaszero balance or does not allowance the spender to tranfer //

    function testFailPlayerDoesNotHaveBalanceOrAllowanceERC20() public {
        // creating players //
        address player = address(1);

        uint256 initialAmount = mockERC20.balanceOf(player);
        assertTrue(initialAmount != 0, "Player Does Not have sufficient balance");
        vm.prank(player);
        uint256 approvedAmount = mockERC20.allowance(player, address(escrowERC20));
        assertTrue(approvedAmount != 0, "Escrow does not have approval of Transfer");
    }
    // function to check the transfer of the tokens //

    function testFuzztransferERC20Tokens(string memory playerAddress, uint256 amount) public {
        // creating Players //
        address player = address(bytes20(bytes(playerAddress)));
        vm.assume(player != address(0)); // assume that player must not be zero address //
        vm.assume(amount > 0);
        vm.assume(amount <= totalSupply);

        // mint a  tokens to escrow  //
        mockERC20.mint(address(escrowERC20), amount);
        amount = amount * (10 ** mockERC20.decimals()); // converting the amount to wei //
        uint256 intialBalance = mockERC20.balanceOf(address(escrowERC20));
        escrowERC20.updateTotalBalance(escrowERC20.totalBalance() + amount); // updating platfrom balance to avoid overflow underflow //

        // to make the transfer doesnot need approve //
        vm.prank(address(escrowERC20));
        escrowERC20.transferTokens(player, address(mockERC20), amount);

        assertEqDecimal(intialBalance, mockERC20.balanceOf(player), mockERC20.decimals(), "Transfer is Not successfull");
    }
    // function to test failure if the escrow does not have totalBalance or doesnot have contractBalance //

    function testFailEscrowOrContractDoesNotHaveBalance() public {
        // checking the platform balance //
        uint256 platformBalance = escrowERC20.totalBalance();
        assertTrue(platformBalance != 0, "Platform Does not have Balance");
        // checking that particular contract has balance //
        uint256 contractBalance = mockERC20.balanceOf(address(escrowERC20));
        assertTrue(contractBalance != 0, "Escrow doesnot own this contract tokens");
    }
}
