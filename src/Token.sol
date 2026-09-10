// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Simple ERC20 with fixed initial mint to a recipient
/// @notice Full initial supply is minted to RECIPIENT. Ownership defaults to the deployer.
contract Token is ERC20, Ownable {
    /// @notice Wallet that receives the entire initial supply at deploy
    address public constant RECIPIENT = 0x20a36F0ddeF3D771Dc68ef2F6b917c0A6036d53c;

    /// @param name_          ERC-20 name
    /// @param symbol_        ERC-20 symbol
    /// @param initialSupply  Amount minted, in smallest units (18 decimals: 1e18 = 1 token)
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(initialSupply > 0, "Supply must be > 0");
        _mint(RECIPIENT, initialSupply); // all tokens go to RECIPIENT

        // If you also want RECIPIENT to be the contract owner (instead of the deployer),
        // uncomment the next line:
        // _transferOwnership(RECIPIENT);
    }
}
