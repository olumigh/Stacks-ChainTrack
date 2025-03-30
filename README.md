# Stacks-ChainTrack - Supply Chain Tracking Smart Contract

## Overview
The **Supply Chain Tracking Smart Contract** is designed to track products throughout their lifecycle in a supply chain. The contract maintains records of ownership, status updates, and location changes for each product.

This smart contract is implemented in Clarity, a language for writing smart contracts on the Stacks blockchain. It ensures transparency, immutability, and security in supply chain operations.

## Features
- **Product Registration**: Only the contract owner can register new products.
- **Ownership Transfer**: A product’s owner can transfer ownership to another entity.
- **Status Updates**: Owners can update a product’s status (e.g., shipped, delivered, inspected, etc.).
- **Product History Tracking**: The complete history of ownership and status changes is recorded.
- **Read-Only Queries**: Retrieve product details and history.

---
## Contract Constants
The following error codes and constants are defined:

- `contract-owner`: The address of the contract owner (who deployed the contract).
- `err-owner-only (u100)`: Error when a non-owner attempts an owner-only action.
- `err-not-found (u101)`: Error when a product ID does not exist.
- `err-unauthorized (u102)`: Error when a non-owner attempts an unauthorized action.
- `err-invalid-status (u103)`: Error for invalid status updates.

---
## Data Structures
### Products
Each product is stored in the `products` map with the following fields:

- `product-id`: A unique identifier (max 36 ASCII characters).
- `manufacturer`: The principal address of the manufacturer.
- `current-owner`: The principal address of the current owner.
- `name`: Product name (max 64 ASCII characters).
- `status`: Current product status (max 20 ASCII characters).
- `timestamp`: The block height when the latest update was made.
- `location`: Current location (max 100 ASCII characters).

### Product History
Each product has an indexed history stored in the `product-history` map:

- `product-id`: Product’s unique identifier.
- `index`: History entry index.
- `owner`: The principal address associated with the change.
- `status`: Status at the time of entry.
- `timestamp`: Block height of the entry.
- `location`: Location at the time of entry.
- `notes`: Additional notes (max 200 ASCII characters).

### History Indices
- Stores the latest index of the product’s history.
- Helps track the length of historical records.

---
## Functions
### Private Functions
#### `is-owner`
Checks if the transaction sender is the contract owner.

#### `get-current-index(product-id)`
Returns the latest index for a product’s history.

#### `increment-history-index(product-id)`
Increments the history index and updates the `history-indices` map.

### Public Functions
#### `register-product(product-id, name, location)`
Registers a new product.
- **Caller**: Contract owner only.
- **Effects**: Creates a new product entry and initializes history.
- **Returns**: `(ok true)` on success.

#### `transfer-ownership(product-id, new-owner, location, notes)`
Transfers a product’s ownership.
- **Caller**: Current owner of the product.
- **Effects**: Updates product ownership and logs it in history.
- **Returns**: `(ok true)` on success.

#### `update-status(product-id, new-status, location, notes)`
Updates a product’s status.
- **Caller**: Current owner of the product.
- **Effects**: Updates the status and logs it in history.
- **Returns**: `(ok true)` on success.

### Read-Only Functions
#### `get-product-details(product-id)`
Retrieves the details of a product.
- **Returns**: Product data or `none` if not found.

#### `get-history-entry(product-id, index)`
Retrieves a specific history entry.
- **Returns**: History entry or `none` if not found.

#### `get-history-length(product-id)`
Gets the total number of history entries for a product.
- **Returns**: The latest history index.

---
## Deployment
1. Deploy the contract using a Clarity-compatible blockchain (e.g., Stacks blockchain).
2. Ensure the deploying principal is the designated contract owner.
3. Interact using a compatible wallet or Clarity smart contract interface.

---
## Usage Example
### Registering a Product (Owner Only)
```clarity
(contract-call? .supply-chain register-product "ABC123" "Laptop" "Factory A")
```

### Transferring Ownership
```clarity
(contract-call? .supply-chain transfer-ownership "ABC123" 'SP3.... "Warehouse X" "Shipped to warehouse")
```

### Updating Product Status
```clarity
(contract-call? .supply-chain update-status "ABC123" "delivered" "Customer Address" "Delivered to customer")
```

### Retrieving Product Details
```clarity
(contract-call? .supply-chain get-product-details "ABC123")
```

### Checking Product History
```clarity
(contract-call? .supply-chain get-history-entry "ABC123" u1)
```

### Getting History Length
```clarity
(contract-call? .supply-chain get-history-length "ABC123")
```

---
## Security Considerations
- **Only the contract owner** can register new products.
- **Only the current owner** of a product can transfer ownership or update the status.
- **Immutable records** ensure transparency and prevent tampering.

---
## Future Enhancements
- Implementing role-based access controls.
- Adding cryptographic verification for product authenticity.
- Integrating IoT tracking for automated updates.

---
## License
This project is open-source under the MIT License.

