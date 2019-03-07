
# MinToken audit report.

# 1. Summary

This document is a security audit report performed by [danbogd](https://github.com/danbogd), where [MinToken](https://github.com/MinToken/MinToken/blob/master/mintoken.sol) has been reviewed.

# 2. In scope

Commit hash:a0d095bb1a375f7b528e7a56d9c8bb00a2dae829
- [mintoken.sol](https://github.com/MinToken/MinToken/blob/master/).


# 3. Findings

In total, **7 issues** were reported including:

 - 2 medium severity issues.
 - 4 low severity issues.
 - 1 minor observation.


No critical security issues were found.

## 3.1. Out Of Gas

### Severity: medium

### Description

For every call to transfer function member of MinValue contract existReceiver function is called to check if the receiver address is listed in receiversMinValueAddr array, the gas consumption can be more expensive each time that a new address is appended to the array, until reaching an "Out of Gas" error or a "Block Gas Limit" in the worst scenario.

Knowing that transfer is one of the most called function in a token contract such implementation can make the function usage very expensive, and that there is no implemented function to reduce the array size.

### Code snippet


https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L126
https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L109

### Recommendation

Implement a mapping instead of an array, a mapping will allow to directly find if an address is listed or not.

Example:
```solidity
    mapping (address => bool) public receiversMinValueAddr;

    function existReceiver(address _ricevente) public constant returns(bool){
            return receiversMinValueAddr[_ricevente];
    }
    
    function setNewReceiverAddr(address _ricevente) onlyOwner public{
        require(_ricevente != 0x0);
    	receiversMinValueAddr[_ricevente] = true;
    }
    
    function removeReceiverAddr(address _ricevente) onlyOwner public{
        receiversMinValueAddr[_ricevente] = false;
    }
```

## 3.2. Owner Privileges

### Severity: medium

### Description


    setNewPercentage reset the percentage to be deducted when a transfer occurs for certain address.
    Freeze & Unfreeze token transfer at any moment without any restriction to a specified address. The owner or a hacker (if the owner's private key will be compromised) can freeze any user at any time, which will make it impossible to transfer funds. This is dangerous for investors and for exchanges too.

### Code snippet

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L77

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L203

## 3.3. Extra Computation

### Severity: low

### Description

_burnPercentageAndTransfer function member of MinValue contract is implemented to burn a percentage of an ongoing transfer to any address listed on receiversMinValueAddr address array, however to burn that percentage burn function can directly be called instead of approve and burnFrom since the msg.sender doesn't need to approve any token value to itself (_burnPercentageAndTransfer function is internal and only called from transfer function member of the same contract).

Also please note, the amount that the msg.sender is approving to itself should be toBurn not _value (this is just a remark the previous definition of the issue should be taken into account first).

### Code snippet

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L104#L105

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L126

## 3.4. Transfer Event

### Severity: minor observation

### Description

When assigning the totalSupply to the msg.sender in the constructor phase a transfer event should be emitted to comply to ERC-20 requirements.

### Code snippet

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L55

## 3.5. 0x0 Address Check

### Severity: low

### Description

    _ricevente address should be checked inside the constructor and it has to be different than 0x0.
    Possibility of setting zero address as newOwner at transferOwnership function.

### Code snippet

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L52

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L15-L17

## 3.6. Known vulnerabilities of ERC-20 token

### Severity: low

### Description

    It is possible to double withdrawal attack. More details here
    Lack of transaction handling mechanism issue. WARNING! This is a very common issue and it already caused millions of dollars losses for lots of token users! More details here

### Recommendation

Add into a function `transfer(address _to, ... )` following code:

```solidity
require( _to != address(this) );

```

## 3.7. Overflow in _calcPercentage function

### Severity: low

### Description

If the user input not correct value in transfer function the overflow occurs, but transfer will reverted due using SafeMath in the function _calcPercentage.

### Code snippet

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L97

https://github.com/MinToken/MinToken/blob/a0d095bb1a375f7b528e7a56d9c8bb00a2dae829/mintoken.sol#L128

# 4. Conclusion

The highlighted issues should be fixed before deployment.


