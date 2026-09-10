# Deploy zktokenx on Base

**Chain:** Base mainnet (chain id `8453`)  
**Fee / mint wallet:** `0x5ca6aD762Fd989dbF6B5Fd0446AA63A7305d7638`

## Before you start

1. Fund that wallet on **Base** with:
   - A little **ETH** for gas (often ~$1–5 is enough for deploy + a few txs)
   - **USDC** (or WETH) for the LP if you want a ~$1 start (`tokens_in_lp ≈ usd_in_lp`)
2. Bridge from another chain via https://bridge.base.org or buy/withdraw directly to Base.

## Foundry deploy

```bash
forge create src/Token.sol:Token \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY \
  --constructor-args 1000000000000000000000000
```

Then on BaseScan verify, add Uniswap/Aerodrome liquidity, and call:

`setAutomatedMarketMakerPair(<PAIR>, true)`

## DEX on Base

Common options: **Uniswap** or **Aerodrome** on Base. After the pair exists, mark it in the contract so fees apply.
