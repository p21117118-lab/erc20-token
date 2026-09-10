# ot21al (ERC-20)

Minimal OpenZeppelin ERC-20 for **p21117118-lab**.

**Name / symbol:** `ot21al`

## Wallet

| | |
|--|--|
| **Mint recipient** | `0x20a36F0ddeF3D771Dc68ef2F6b917c0A6036d53c` |
| **GitHub** | [p21117118-lab](https://github.com/p21117118-lab) |

At deploy, the full `initialSupply` is minted to `RECIPIENT`. Ownership stays with the deployer unless you uncomment `_transferOwnership(RECIPIENT)` in `src/Token.sol`.

## Setup (Foundry)

```bash
curl -L https://foundry.paradigm.xyz | bash && foundryup
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std
```

## Test

```bash
forge test -vv
```

## Deploy

```bash
forge create src/Token.sol:Token \
  --constructor-args 1000000000000000000000000 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

`initialSupply` is in smallest units. For 1M tokens at 18 decimals, use `1_000_000e18`.
