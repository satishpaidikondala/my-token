// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    // -----------------------------------------
    // STATE VARIABLES (Token Metadata & Storage)
    // -----------------------------------------
    
    // 1. Token Identity
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18; // 18 is the standard for Ethereum tokens
    
    // 2. Token Supply
    uint256 public totalSupply;

    // 3. Balance Tracking ( The Ledger )
    // Think of this like a spreadsheet: Address column -> Balance column
    mapping(address => uint256) public balanceOf;

    // 4. Allowance Tracking
    // Used when you let someone else spend your tokens (like a debit card limit)
    // Owner Address -> (Spender Address -> Allowed Amount)
    mapping(address => mapping(address => uint256)) public allowance;

    // -----------------------------------------
    // EVENTS (For transparency and blockchain logging)
    // -----------------------------------------
    
    // Emitted whenever tokens move (minting, transferring, burning)
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Emitted whenever an owner approves a spender
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // -----------------------------------------
    // CONSTRUCTOR (Runs once on deployment)
    // -----------------------------------------
    
    constructor(uint256 _initialSupply) {
        // Set the total supply to what you input during deployment
        totalSupply = _initialSupply;
        
        // Give all the tokens to the contract creator (You)
        balanceOf[msg.sender] = totalSupply;
    }
    // -----------------------------------------
    // CORE FUNCTIONS
    // -----------------------------------------

    /**
     * @dev Moves `_value` tokens from caller's account to `_to`.
     * Returns a boolean value indicating whether the operation succeeded.
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // 1. SAFETY CHECK: Validate recipient is not the zero address (burning)
        require(_to != address(0), "Cannot transfer to zero address");
        
        // 2. SAFETY CHECK: Validate sender has sufficient balance
        // msg.sender = the person clicking the button
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        // 3. UPDATE LEDGER: Deduct from sender
        balanceOf[msg.sender] -= _value;
        
        // 4. UPDATE LEDGER: Add to recipient
        balanceOf[_to] += _value;

        // 5. NOTIFY: Emit the Transfer event so wallets know what happened
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
    /**
     * @dev Sets `_value` as the allowance of `_spender` over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // 1. SAFETY CHECK: Validate spender is not zero address
        require(_spender != address(0), "Cannot approve zero address");

        // 2. UPDATE LEDGER: Set the allowance
        // Logic: Mapping[Owner][Spender] = Amount
        allowance[msg.sender][_spender] = _value;

        // 3. NOTIFY: Emit the Approval event
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }
    /**
     * @dev Moves `_value` tokens from `_from` to `_to` using allowance mechanism.
     * Returns a boolean value indicating whether the operation succeeded.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // 1. SAFETY CHECK: Validate recipient
        require(_to != address(0), "Cannot transfer to zero address");
        
        // 2. SAFETY CHECK: Validate balance of the owner (the person paying)
        require(balanceOf[_from] >= _value, "Insufficient balance");
        
        // 3. SAFETY CHECK: Validate allowance
        // Check if msg.sender (the spender) is allowed to move this much
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");

        // 4. UPDATE LEDGER: Deduct from owner
        balanceOf[_from] -= _value;
        
        // 5. UPDATE LEDGER: Add to recipient
        balanceOf[_to] += _value;
        
        // 6. UPDATE ALLOWANCE: Decrease the limit
        // We must reduce the allowance so they can't spend the same amount twice!
        allowance[_from][msg.sender] -= _value;

        // 7. NOTIFY: Emit the Transfer event
        // Note: We emit 'Transfer', not 'TransferFrom' (which doesn't exist)
        emit Transfer(_from, _to, _value);
        
        return true;
    }
    // -----------------------------------------
    // HELPER FUNCTIONS (Optional for convenience)
    // -----------------------------------------

    // Explicit function to get total supply 
    // (Note: The public variable 'totalSupply' already created a getter, 
    // but this ensures compatibility with tools expecting a specific function signature)
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    // Function to get all token details in a single call
    // Returns: (Name, Symbol, Decimals, TotalSupply)
    function getTokenInfo() public view returns (string memory, string memory, uint8, uint256) {
        return (name, symbol, decimals, totalSupply);
    }
} 
