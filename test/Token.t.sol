// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token internal token;
    address internal constant FEE_WALLET = 0x8a5c3610d80f87EA38816b072cdB000C80Fe42F0;
    address internal pair = address(0x1111);
    address internal trader = address(0x2222);
    uint256 internal constant SUPPLY = 1_000_000 ether;

    function setUp() public {
        token = new Token(SUPPLY);
        token.setAutomatedMarketMakerPair(pair, true);
        // Fund pair + trader from fee wallet for transfer tests
        vm.prank(FEE_WALLET);
        token.transfer(pair, 100_000 ether);
        vm.prank(FEE_WALLET);
        token.transfer(trader, 100_000 ether);
    }

    function test_NameSymbolAndMint() public view {
        assertEq(token.name(), "zktokenx");
        assertEq(token.symbol(), "ZKTX");
        assertEq(token.totalSupply(), SUPPLY);
        assertEq(token.balanceOf(FEE_WALLET), SUPPLY - 200_000 ether);
        assertEq(token.FEE_WALLET(), FEE_WALLET);
        assertEq(token.RECIPIENT(), FEE_WALLET);
    }

    function test_BuyTaxGoesToFeeWallet() public {
        uint256 feeBefore = token.balanceOf(FEE_WALLET);
        uint256 tradeAmount = 10_000 ether;
        uint256 expectedFee = (tradeAmount * token.buyTaxBps()) / 10_000;

        vm.prank(pair);
        token.transfer(trader, tradeAmount);

        assertEq(token.balanceOf(FEE_WALLET), feeBefore + expectedFee);
        assertEq(token.balanceOf(trader), 100_000 ether + (tradeAmount - expectedFee));
    }

    function test_SellTaxGoesToFeeWallet() public {
        uint256 feeBefore = token.balanceOf(FEE_WALLET);
        uint256 tradeAmount = 10_000 ether;
        uint256 expectedFee = (tradeAmount * token.sellTaxBps()) / 10_000;

        vm.prank(trader);
        token.transfer(pair, tradeAmount);

        assertEq(token.balanceOf(FEE_WALLET), feeBefore + expectedFee);
        assertEq(token.balanceOf(pair), 100_000 ether + (tradeAmount - expectedFee));
    }

    function test_WalletToWalletNoTax() public {
        address other = address(0x3333);
        uint256 feeBefore = token.balanceOf(FEE_WALLET);

        vm.prank(trader);
        token.transfer(other, 1_000 ether);

        assertEq(token.balanceOf(other), 1_000 ether);
        assertEq(token.balanceOf(FEE_WALLET), feeBefore);
    }

    function test_ExcludedFromFeeSkipsTax() public {
        token.setExcludedFromFee(trader, true);
        uint256 feeBefore = token.balanceOf(FEE_WALLET);

        vm.prank(trader);
        token.transfer(pair, 5_000 ether);

        assertEq(token.balanceOf(FEE_WALLET), feeBefore);
    }

    function test_TaxCapEnforced() public {
        vm.expectRevert(bytes("Buy tax too high"));
        token.setBuyTaxBps(1_001);

        vm.expectRevert(bytes("Sell tax too high"));
        token.setSellTaxBps(1_001);

        token.setBuyTaxBps(1_000);
        token.setSellTaxBps(1_000);
        assertEq(token.buyTaxBps(), 1_000);
        assertEq(token.sellTaxBps(), 1_000);
    }

    function test_RevertWhenSupplyZero() public {
        vm.expectRevert(bytes("Supply must be > 0"));
        new Token(0);
    }

    function test_AnyoneCanSellWithFee() public {
        // Honeypot check: non-owner trader can sell to pair
        vm.prank(trader);
        bool ok = token.transfer(pair, 100 ether);
        assertTrue(ok);
    }
}
