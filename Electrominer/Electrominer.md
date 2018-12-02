
# electrominer.io pre ICO Audit Report.

# 1. Summary

This document is a security audit report performed by [danbogd](https://github.com/danbogd), where [electrominer.io pre ICO](https://gist.github.com/yuriy77k/771837a9b54d81157a27496d50fff1bb) has been reviewed.

# 2. In scope

- [electrominer.sol](https://gist.github.com/yuriy77k/771837a9b54d81157a27496d50fff1bb).

# 3. Findings

**3 issues** were reported including:

- 1 low severity issues.
- 2 minor observation.

## 3.1. Owner Permissions

### Severity: low

### Description

he contract owner has multiple permissions:

set ETH/USD rate.
ICO stages can be restarted at will, even after the end of stage is called.
Send tokens from the allocated crowdsale tokens.
Multiple possible issues can be raised:

Hack of private keys.
Price manipulation.
Stages reopening.
etc ...
Investors and developers should be aware of such practice and be informed about the risks.

### Code snippet

https://gist.github.com/RideSolo/25ebbfa61fea3c8f49e107ab961ed6d2#file-electrominer-sol-L601#L604

https://gist.github.com/RideSolo/25ebbfa61fea3c8f49e107ab961ed6d2#file-electrominer-sol-L514#L543

https://gist.github.com/RideSolo/25ebbfa61fea3c8f49e107ab961ed6d2#file-electrominer-sol-L245#L290

## 3.2. Extra if statement.

### Severity: minor observation

### Description

If statement is extra, because there is require that will check this condition.

### Recommendation

If statement could be deleted.

## 3.3. Crowdsale Hard Cap.

### Severity: minor observation

### Description

The crowdsale hard cap is set to be 50M USD (as per the white paper), with a total of 70000000 on sale and a price of 0.7142 USD per token (as per the white paper) the hard cap will be almost 50M.
In general hard cap can not be reached if the tokens are not all sold, however here, since the bonuses are also distributed from the 70M tokens allowed for the crowdsale only ~37.19M USD will be collected (if the ETH/USD rate is set frequently and all the tokens are sold).

### Code snippet

https://gist.github.com/RideSolo/25ebbfa61fea3c8f49e107ab961ed6d2#file-electrominer-sol-L137#L142

https://gist.github.com/RideSolo/25ebbfa61fea3c8f49e107ab961ed6d2#file-electrominer-sol-L162#L167

https://gist.github.com/RideSolo/25ebbfa61fea3c8f49e107ab961ed6d2#file-electrominer-sol-L451#L482

https://gist.github.com/RideSolo/25ebbfa61fea3c8f49e107ab961ed6d2#file-electrominer-sol-L355#L360

## 4. Conclusion
No critical vulnerabilities were detected,but we highly recommend to complete this bugs before use.

