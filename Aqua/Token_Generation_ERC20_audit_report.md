
# Token Generation for ERC20 Audit Report.

# 1. Summary

This document is a security audit report performed by [danbogd](https://github.com/danbogd), where [Token Generation for ERC20](https://gist.github.com/yuriy77k/64fcfd4cd9bc7678711b6d85500ea79a) has been reviewed.

# 2. In scope

- [AQX_2.sol](https://gist.github.com/yuriy77k/64fcfd4cd9bc7678711b6d85500ea79a).

# 3. Findings

**2 issues** were reported including:

- 1 low severity issues.

- 1 minor remark.

## 3.1. Known Issues of ERC20 Standard

### Severity: low

### Description

ERC20 Tokens have some well-known issues (listed bellow), This is just a reminder for the contract developers.

Approve + transferFrom mechanism allows double Withdrawal attack.
Lack of transaction handling.

The above mentioned issues are well documented, a basic search can help to get more information.

## 3.2. Old solidity version. 

### Severity: minor

### Description

Used solidity version is old. 

### Recommendation

Use one of the latest version of solidity.

## 4. Conclusion
No critical vulnerabilities were detected,but we highly recommend to complete this bugs before use.

