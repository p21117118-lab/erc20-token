// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title zktokenx — ERC-20 with transparent buy/sell trading fees
/// @notice Fees from DEX buys/sells are sent to FEE_WALLET (same as initial mint recipient).
///         This is not a honeypot: anyone can sell subject to the published sell fee.
///         Revenue only appears if there is real trading volume and liquidity — the contract
///         does not create demand or guarantee profit.
contract Token is ERC20, Ownable {
    /// @notice Receives initial supply and all trading fees
    address public constant FEE_WALLET = 0x5ca6aD762Fd989dbF6B5Fd0446AA63A7305d7638;

    /// @dev Alias kept for clarity with earlier versions
    address public constant RECIPIENT = FEE_WALLET;

    uint16 public constant MAX_TAX_BPS = 1_000; // 10.00%

    /// @notice Buy tax in basis points (100 = 1%)
    uint16 public buyTaxBps = 300; // 3%

    /// @notice Sell tax in basis points
    uint16 public sellTaxBps = 300; // 3%

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isAutomatedMarketMakerPair;

    event BuyTaxUpdated(uint16 oldTax, uint16 newTax);
    event SellTaxUpdated(uint16 oldTax, uint16 newTax);
    event ExcludedFromFee(address account, bool excluded);
    event AutomatedMarketMakerPairSet(address pair, bool indexed value);

    /// @param initialSupply Amount minted to FEE_WALLET, in smallest units (1e18 = 1 token)
    constructor(uint256 initialSupply) ERC20("zktokenx", "ZKTX") Ownable(msg.sender) {
        require(initialSupply > 0, "Supply must be > 0");

        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[FEE_WALLET] = true;

        _mint(FEE_WALLET, initialSupply);
    }

    function setBuyTaxBps(uint16 newTax) external onlyOwner {
        require(newTax <= MAX_TAX_BPS, "Buy tax too high");
        emit BuyTaxUpdated(buyTaxBps, newTax);
        buyTaxBps = newTax;
    }

    function setSellTaxBps(uint16 newTax) external onlyOwner {
        require(newTax <= MAX_TAX_BPS, "Sell tax too high");
        emit SellTaxUpdated(sellTaxBps, newTax);
        sellTaxBps = newTax;
    }

    function setExcludedFromFee(address account, bool excluded) external onlyOwner {
        isExcludedFromFee[account] = excluded;
        emit ExcludedFromFee(account, excluded);
    }

    /// @notice Mark a liquidity pool pair so buys/sells can be taxed
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != address(0), "Zero pair");
        isAutomatedMarketMakerPair[pair] = value;
        emit AutomatedMarketMakerPairSet(pair, value);
    }

    function _update(address from, address to, uint256 amount) internal override {
        if (amount == 0) {
            super._update(from, to, 0);
            return;
        }

        // Mint / burn paths (from or to zero) — no fee
        if (from == address(0) || to == address(0)) {
            super._update(from, to, amount);
            return;
        }

        bool takeFee = !isExcludedFromFee[from] && !isExcludedFromFee[to];
        uint256 fee;

        if (takeFee) {
            if (isAutomatedMarketMakerPair[from] && buyTaxBps > 0) {
                // Buy: pair -> trader
                fee = (amount * buyTaxBps) / 10_000;
            } else if (isAutomatedMarketMakerPair[to] && sellTaxBps > 0) {
                // Sell: trader -> pair
                fee = (amount * sellTaxBps) / 10_000;
            }
        }

        if (fee > 0) {
            super._update(from, FEE_WALLET, fee);
            super._update(from, to, amount - fee);
        } else {
            super._update(from, to, amount);
        }
    }
}
