# ot21al (ERC-20 + trading fees)

Token for **p21117118-lab** with a **transparent buy/sell fee** that pays the creator wallet when people trade against a marked liquidity pool.

**Name / symbol:** `ot21al`  
**Target launch price (via LP):** **$1.00** per token

## Important (read this)

- This contract does **not** guarantee profit. Fees only show up if there is **real liquidity and volume**.
- Online “make money with a token” content often skips the hard parts (liquidity, buyers, compliance) or pushes scams. **This is not a honeypot** — holders can sell; sells take the published sell fee.
- You are responsible for taxes, securities/commodities rules, and how you market this.

## Wallet

| | |
|--|--|
| **Fee + mint recipient** | `0x20a36F0ddeF3D771Dc68ef2F6b917c0A6036d53c` |
| **GitHub** | [p21117118-lab](https://github.com/p21117118-lab) |

## Launch price ≈ $1.00

Uniswap V2-style pools set price from reserves:

`price ≈ (stablecoin or ETH-in-USD in the pool) / (ot21al tokens in the pool)`

To open near **$1.00**:

`tokens_in_lp = usd_in_lp / 1.00`  
(equal USD and token amounts in the pool)

Examples:

| USD (or stable) in LP | `ot21al` to pair at $1 |
|----------------------|------------------------|
| $50 | 50 tokens |
| $100 | 100 tokens |
| $1,000 | 1,000 tokens |

Only put a **slice** of total supply in the LP. Keep the rest in your fee wallet (or distribute later). Thin LP can still quote $1, but large buys will move the price hard.

After the pair exists, call `setAutomatedMarketMakerPair(pair, true)`.

## How creator revenue works

1. Deploy and mint full supply to the fee wallet.
2. Add liquidity on a DEX at the ratio above for ~$1.
3. Call `setAutomatedMarketMakerPair(pair, true)`.
4. Default taxes: **3% buy** / **3% sell** (owner can change up to **10%** max).
5. On each taxed buy/sell, the fee amount goes to `FEE_WALLET`.

Wallet-to-wallet transfers are **not** taxed by default.

## Setup (Foundry)

```bash
curl -L https://foundry.paradigm.xyz | bash && foundryup
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std
forge test -vv
```

## Deploy

```bash
forge create src/Token.sol:Token \
  --constructor-args 1000000000000000000000000 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

`initialSupply` is in smallest units (`1_000_000e18` = 1M tokens at 18 decimals).
