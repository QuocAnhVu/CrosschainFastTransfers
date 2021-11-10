# Core

Chains must have the same contract addresses.
Chains must provide a CHAIN_ID that is in the same canonical namespace.

# Networking Extension

Chain must have a Messenger contract that allows for cross-chain calls:

```sol
contract Messenger {
    function sendMessage(
        address _crosschainTarget,
        bytes memory _message,
        uint32 _gasLimit
    )
}
```