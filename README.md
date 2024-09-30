# PancakeSwap v4 Identity Verification System

## Overview

This project implements a robust identity verification system for PancakeSwap v4 using zero-knowledge proofs. It leverages the Brevis ZK-Coprocessor to verify user identities while maintaining privacy. The system is designed to work with both Concentrated Liquidity (CL) and Bin pools in PancakeSwap v4.

## Key Components

1. **BrevisZKCoprocessor**: 
   - Core component for verifying zero-knowledge proofs.
   - Supports individual and batch proof verification.
   - Upgradeable and parameter-adjustable for future improvements.

2. **BaseIdentityHook**:
   - Abstract contract providing common identity verification functionality.
   - Manages user identity data and verification statuses.
   - Integrates with BrevisZKCoprocessor for proof verification.

3. **CLIdentityHook**:
   - Extends BaseIdentityHook for Concentrated Liquidity pools.
   - Implements specific swap checks for CL pools.

4. **BinIdentityHook**:
   - Extends BaseIdentityHook for Bin pools.
   - Implements specific swap checks for Bin pools.

5. **AdminDashboard**:
   - Centralized management interface for the identity verification system.
   - Allows administrators to control both CL and Bin hooks.
   - Provides system-wide statistics and control functions.

## Key Functionalities

### 1. Identity Verification
- Users can submit zero-knowledge proofs to verify their identity.
- The system supports different verification levels (Unverified, Basic, Advanced, Premium).
- Verification has a cooldown period to prevent abuse.

### 2. Swap Checks
- Before each swap, the system checks if the user is verified.
- Different pools (CL and Bin) have tailored checks implemented.

### 3. Admin Controls
- Admins can pause/unpause the system.
- Identity revocation for specific users.
- Updating the BrevisZKCoprocessor address.

### 4. ZK Proof Verification
- The BrevisZKCoprocessor verifies submitted proofs.
- Supports both individual and batch verification.
- Prevents replay attacks by tracking used proofs.

### 5. Upgradability
- Key contracts are upgradeable, allowing for future improvements without losing state.

## Setup and Deployment

### Prerequisites
- [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
- [Node.js](https://nodejs.org/) (v14 or later)
- [Yarn](https://yarnpkg.com/) or [npm](https://www.npmjs.com/)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/your-repo/pancakeswap-v4-identity-verification.git
   cd pancakeswap-v4-identity-verification
   ```

2. Install dependencies:
   ```
   forge install
   ```

3. Copy `.env.example` to `.env` and fill in the required values:
   ```
   cp .env.example .env
   ```

### Compilation

Compile the contracts:
```
forge build
```

### Testing

Run the test suite:
```
forge test
```

For more verbose output:
```
forge test -vvv
```

### Deployment

1. Deploy to a local network for testing:
   ```
   forge script script/DeployIdentityHooks.s.sol:DeployIdentityHooks --broadcast --fork-url http://localhost:8545
   ```

2. Deploy to a live network (e.g., mainnet):
   ```
   forge script script/DeployIdentityHooks.s.sol:DeployIdentityHooks --rpc-url $RPC_URL --broadcast --verify -vvvv
   ```

   Make sure to replace `$RPC_URL` with the appropriate RPC endpoint.

## Usage

After deployment, interact with the contracts using a web3 provider or directly through etherscan:

1. Users submit ZK proofs for verification through the CLIdentityHook or BinIdentityHook.
2. Admins can manage the system through the AdminDashboard contract.
3. The BrevisZKCoprocessor automatically verifies proofs during the identity verification process.

## Security Considerations

- Ensure that only authorized addresses have admin roles.
- Regularly audit and update the ZK proof verification logic in the BrevisZKCoprocessor.
- Monitor system activity for any unusual patterns that might indicate abuse.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and write tests.
4. Submit a pull request with a clear description of your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.