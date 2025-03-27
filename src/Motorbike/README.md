# 25. Motorbike

**NOTE** - Because of the way foundry test work it is very hard to verify this test was successful, Selfdestruct is a substate (see pg 8 https://ethereum.github.io/yellowpaper/paper.pdf). This means it gets executed at the end of a transaction, a single test is a single transaction. This means we can call selfdestruct on the engine contract at the start of the test but we will continue to be allowed to call all other contract function for the duration of that transaction (test) since the selfdestruct execution only happy at the end

## Foundry

```
forge test --match-contract MotorbikeTest -vvvv
```
