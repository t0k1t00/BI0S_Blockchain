Ethernaut Level0: Hello Ethernaut

## Commands I Used

### 1. Called info() to get the initial clue
```
await contract.info()
```
**Output:**  
`"You will find what you need in info1()."`

**Reason:** This was the first hint given in the level.

---

### 2. Inspected the contract object
```
await contract
```
**Reason:** To check what functions are available in the contract. I noticed a password() function.

---

### 3. Retrieved the password
```
await contract.password()
```
**Output:**  
`"ethernaut0"`

**Reason:** This is the password needed for authentication.

---

### 4. Submitted the password directly
```
await contract.authenticate(await contract.password())
```
**Output:**  
Transaction successful

### 5. Clicked "Submit Instance"  
Level completed 

##🖼️ Output Proof##
![Level Complete Output](assets/Hello_Ethernaut.png)
![2](assets/Hello_Ethernaut(1).png)
