
# Natmin Audit Report.

# 1. Summary

This document is a security audit report performed by [danbogd](https://github.com/danbogd), where [Natmin](https://github.com/NatminPureEscrow/Token) has been reviewed.

# 2. In scope

- [NatminToken.sol](https://github.com/NatminPureEscrow/Token/blob/master/contracts/NatminToken.sol) github commit hash fcfdf37b07ba613bf8ca4ecd566865344e72dd82.

# 3. Findings

**5 issues** were reported including:

- 1 medium severity issues.

- 3 low severity issues.

- 1 minor observation.

## 3.1. ERC223 Standard Compliance

### Severity: medium

### Description

The reviewed token contract is not ERC223 fully compliant, transferToContract function member of NatminToken contract call tokenFallback external function on the receiver contract before adding the value to balances[_to]. The original implementation adds the token value to the balance before making the external call (check the link below).

https://github.com/Dexaran/ERC223-token-standard/blob/master/token/ERC223/ERC223_token.sol#L63#L68

Different issues can be raised depending on tokenFallBack implementation on the receiver contract. A good example is if the contract tries to move the tokens from its balance when the tokens are not yet added to it.

### Code snippet

https://github.com/NatminPureEscrow/Token/blob/master/contracts/NatminToken.sol#L188#L224

## 3.2. Token Transfer to Address 0x0

### Severity: low

### Description

It is possible to accidentally send tokens to 0x0 address then _to parameter will not be set in transfer function call. Functions transfer(ERC20), transfer (erc223), transferFrom of contract NatminToken.

### Code snippet

https://github.com/NatminPureEscrow/Token/blob/fcfdf37b07ba613bf8ca4ecd566865344e72dd82/contracts/NatminToken.sol#L156-L164
https://github.com/NatminPureEscrow/Token/blob/fcfdf37b07ba613bf8ca4ecd566865344e72dd82/contracts/NatminToken.sol#L166-L173
https://github.com/NatminPureEscrow/Token/blob/fcfdf37b07ba613bf8ca4ecd566865344e72dd82/contracts/NatminToken.sol#L219-L232

### Recommendation

Use condition to check 0x0 address.

```require(_to != address(0));```

## 3.3. No need of require.

### Severity: minor observation

### Description

SafeMath.sub() will automatically throw, if someone will try send more, than he has. In transfer and transferFrom functions no need to check it with require.

### Code snippet
https://github.com/NatminPureEscrow/Token/blob/fcfdf37b07ba613bf8ca4ecd566865344e72dd82/contracts/NatminToken.sol#L189
https://github.com/NatminPureEscrow/Token/blob/fcfdf37b07ba613bf8ca4ecd566865344e72dd82/contracts/NatminToken.sol#L208
https://github.com/NatminPureEscrow/Token/blob/fcfdf37b07ba613bf8ca4ecd566865344e72dd82/contracts/NatminToken.sol#L222

### Recommendation

In lines 189, 208, 222 no need of require.

## 3.4. Vesting Logic.

### Severity: low

### Description

If the owner set a vesting amount and an end time for a user using addVesting function, and if the user receives tokens from another address, he won't be able to transfer the extra amount even if balancesOf[user] > vestings[user].amount.

Actually purpose of vestings[user].amount is unclear. It used only in function getVestedAmount, but this function is unused in contract.

### Code snippet

https://github.com/NatminPureEscrow/Token/blob/master/contracts/NatminToken.sol#L274#L277

https://github.com/NatminPureEscrow/Token/blob/master/contracts/NatminToken.sol#190

https://github.com/NatminPureEscrow/Token/blob/master/contracts/NatminToken.sol#209

## 3.5. Known vulnerabilities of ERC-20 token

### Severity: low

### Description

It is possible to double withdrawal attack. More details [here](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit).

## 4. Conclusion
No critical vulnerabilities were detected,but we highly recommend to complete this bugs before use.

