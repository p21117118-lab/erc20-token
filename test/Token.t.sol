// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token internal token;
    address internal constant RECIPIENT = 0x20a36F0ddeF3D771Dc68ef2F6b917c0A6036d53c;
    uint256 internal constant SUPPLY = 1_000_000 ether;

    function setUp() public {
        token = new Token(SUPPLY);
    }

    function test_NameAndSymbol() public view {
        assertEq(token.name(), "ot21al");
        assertEq(token.symbol(), "ot21al");
    }

    function test_InitialSupplyGoesToRecipient() public view {
        assertEq(token.totalSupply(), SUPPLY);
        assertEq(token.balanceOf(RECIPIENT), SUPPLY);
        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.RECIPIENT(), RECIPIENT);
        assertEq(token.owner(), address(this));
    }

    function test_RevertWhenSupplyZero() public {
        vm.expectRevert(bytes("Supply must be > 0"));
        new Token(0);
    }
}
