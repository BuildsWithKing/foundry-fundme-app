```markdown
# 💰 FundMe Smart Contract – Built with Foundry

This is a fully functional smart contract project built in Solidity using [Foundry](https://book.getfoundry.sh/) and follows modern best practices in contract development, testing, and gas optimization.

> 👨‍💻 Created by: [@BuildsWithKing](https://github.com/BuildsWithKing)  
> 🚀 Goal: To build a decentralized funding mechanism that accepts ETH and allows the owner to withdraw funds.  
> 🧠 Status: ✅ Completed core functionality + ✅ full unit testing suite.

---

## 🔧 Tech Stack

- **Solidity** `^0.8.18`
- **Foundry** for testing & scripting
- **Chainlink Price Feeds** (AggregatorV3Interface)
- **Cheatcodes** (`vm`, `hoax`, `prank`, etc.) for deep test coverage

---

## 📂 Project Structure

```

.
├── src
│   └── FundMe.sol            # Main FundMe contract
│   └── PriceConverter.sol    # Library for ETH → USD conversion
├── test
│   └── unit/FundMe.t.sol     # Unit tests for FundMe
├── script
│   └── DeployFundMe.s.sol    # Deployment script
├── foundry.toml              # Project config
└── README.md                 # You're here!

````

---

## 🧠 What This Project Does

- ✅ Accepts ETH from users
- ✅ Requires minimum $5 USD worth of ETH (uses Chainlink Oracle)
- ✅ Tracks funders and their contributions
- ✅ Only contract owner can withdraw funds
- ✅ Supports optimized and gas-efficient withdrawal logic
- ✅ Accepts plain ETH transfers via `receive()` and `fallback()`

---

## 🛠️ Smart Contract Concepts Demonstrated

| 🔍 Concept                  | ✅ Usage Example                                        |
| -------------------------- | ------------------------------------------------------ |
| `mapping`                  | Tracks who funded and how much                         |
| `immutable` / `constant`   | Save gas, used for owner and minimum USD constant      |
| `onlyOwner` modifier       | Protect `withdraw()` and `cheaperWithdraw()` functions |
| `custom error`             | Uses `FundMe__NotOwner()` to reduce gas for reverts    |
| `receive()` & `fallback()` | Accepts direct ETH transfers to contract               |
| Chainlink Oracle           | Real-time ETH → USD price conversion                   |
| Gas Optimization           | Using local vars, `cheaperWithdraw()`, `memory` tricks |

---

## 🔬 Testing

Tests are written using Foundry's built-in Forge testing framework. They cover:

- ✅ Funding with ETH above/below threshold
- ✅ Owner-only access
- ✅ Updating internal mappings correctly
- ✅ Withdrawal by single and multiple funders
- ✅ Gas-optimized withdraw logic

### Run All Tests:

```bash
forge test -vvvv
````

---

## ✅ Sample Test Logic

```solidity
function test_FundFailsWithoutEnoughETH() public {
    vm.expectRevert();
    fundMe.fund(); // sending 0 ETH
}

function test_OnlyOwnerCanWithdraw() public funded {
    vm.prank(USER);
    vm.expectRevert();
    fundMe.withdraw();
}

function test_WithdrawWithASingleFunder() public funded {
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingContractBalance = address(fundMe).balance;

    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    assertEq(address(fundMe).balance, 0);
    assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingContractBalance);
}
```

---

## 🔒 Security Highlights

* ✅ Reverts non-owner withdrawals
* ✅ Resets funder data after withdrawals
* ✅ Uses `call()` for secure ETH transfers
* ✅ Receives ETH via `fallback` and `receive`
* ✅ Gas-optimized for production

---

## 👨‍🎓 Learning Goals

This project is part of my journey through the **Cyfrin Updraft** Foundry course, where I’m learning:

* Writing smart contracts from scratch
* Building automated test systems
* Gas optimization techniques
* Deployment scripting
* GitHub project publishing

---

## 🙏 Credits

* Built by: [@BuildsWithKing](https://github.com/BuildsWithKing)
* Instructor: [Patrick Collins (Cyfrin)](https://github.com/PatrickAlphaC)
* Chainlink Docs: [https://docs.chain.link/](https://docs.chain.link/)
* Foundry Docs: [https://book.getfoundry.sh/](https://book.getfoundry.sh/)

---

## 📜 License

This project is licensed under the MIT License.
Feel free to use, modify, and learn from it.

```
//SPDX-License-Identifier: MIT

```