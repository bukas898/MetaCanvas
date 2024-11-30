# Digital Art Authentication and Licensing System (DAALS)  

**Project Overview**  
The Digital Art Authentication and Licensing System (DAALS) is a smart contract application built on the Stacks blockchain. It provides a secure and transparent platform for authenticating digital artwork, managing licensing, and tracking ownership history. By leveraging blockchain technology, DAALS ensures that artists, galleries, and collectors can trust the authenticity and licensing status of digital artworks.

---

## Features  
1. **Artwork Registration**:  
   - Artists can register their digital artwork with details such as the artist name, collection, and a unique token ID.  
   - Automatically tracks the creation timestamp and assigns the creator as the initial licensee.  

2. **License Transfer**:  
   - Enables transferring artwork licenses securely between users (e.g., from artist to gallery).  
   - Records all license transfers in a historical ledger for transparency.

3. **Artwork Verification**:  
   - Provides a mechanism to verify the authenticity of digital artworks.  
   - Ensures only authorized creators and galleries are listed.

4. **License Status Management**:  
   - Allows creators to update the license status of their artworks (e.g., valid, revoked, or expired).

5. **License History Tracking**:  
   - Maintains a comprehensive history of all license-related actions, including transfers and updates.

---

## Architecture  
The system is implemented using Clarity smart contracts and comprises the following core components:  

- **Data Maps**:  
  - `artworks`: Stores metadata about each artwork.  
  - `license-history`: Tracks the history of licenses for each artwork.  
  - `creators` and `galleries`: Registers authorized creators and galleries.  

- **Constants**:  
  - Define reusable values like error codes and license statuses.  

- **Read-Only Functions**:  
  - `get-artwork`: Fetch artwork details.  
  - `is-creator` and `is-gallery`: Check authorization for creators and galleries.  
  - `get-license-history`: Retrieve license history records.

- **Public Functions**:  
  - `register-creator` and `register-gallery`: Add authorized creators and galleries.  
  - `mint-artwork`: Register a new artwork.  
  - `transfer-license`: Transfer license ownership.  
  - `verify-artwork`: Validate authenticity.  
  - `update-license-status`: Modify the license status.

---

## Installation  

### Prerequisites  
- [Stacks Blockchain CLI](https://docs.hiro.so/get-started)  
- Node.js (for running a local development server if needed)  
- A text editor like VS Code  

### Steps  
1. Clone the repository:  
   ```bash
   git clone https://github.com/your-repo/DAALS.git
   cd DAALS
   ```  
2. Deploy the contract:  
   - Use the Stacks CLI to deploy the Clarity smart contract:  
     ```bash
     clarity-cli deploy ./contracts/daals.clar
     ```  

3. Test the contract (optional):  
   - Write and run test cases in Clarity to validate the functionality.  

---

## Usage  

### Artwork Registration  
1. Register yourself as a creator using the `register-creator` function.  
   Example:  
   ```clarity
   (contract-call? .daals register-creator tx-sender)
   ```  
2. Mint a new artwork:  
   ```clarity
   (contract-call? .daals mint-artwork "unique-token-id" "artist-name" "collection-name")
   ```  

### Transferring Licenses  
To transfer a license to a new owner:  
```clarity
(contract-call? .daals transfer-license "unique-token-id" new-licensee-principal)
```  

### Verifying Artworks  
To verify the authenticity of an artwork:  
```clarity
(contract-call? .daals verify-artwork "unique-token-id")
```  

### Updating License Status  
To update the license status (e.g., revoke or expire):  
```clarity
(contract-call? .daals update-license-status "unique-token-id" "revoked")
```  

---

## Error Codes  
- `ERR_NOT_AUTHORIZED (u100)`: The caller does not have permission.  
- `ERR_INVALID_INPUT (u101)`: Invalid input provided.  
- `ERR_NOT_FOUND (u102)`: The requested artwork or record does not exist.  
- `ERR_ALREADY_EXISTS (u103)`: The artwork or record already exists.  
- `ERR_INVALID_STATUS (u104)`: Invalid license status provided.  

---

## Roadmap  
1. **Phase 1**: Initial release with core features for registration, transfer, and verification.  
2. **Phase 2**: Integration with NFT standards for tokenized artworks.  
3. **Phase 3**: Build a web-based interface for creators and galleries.  
4. **Phase 4**: Support for multi-chain compatibility.  

---

## Contributing  
Contributions are welcome! Please fork the repository and submit a pull request with your changes.  

---


## Contact  
For any inquiries or suggestions, please contact **Amobi Ndubuisi** at dev.triggerfish@gmail.com.  

