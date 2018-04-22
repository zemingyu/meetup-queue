pragma solidity ^0.4.18;

import "./BTTSLib.sol";

// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Token v1.10
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------
contract BTTSToken is BTTSTokenInterface {
    using BTTSLib for BTTSLib.Data;

    BTTSLib.Data data;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function BTTSToken(address owner, string symbol, string name, uint8 decimals, uint initialSupply, bool mintable, bool transferable) public {
        data.init(owner, symbol, name, decimals, initialSupply, mintable, transferable);
    }

    // ------------------------------------------------------------------------
    // Ownership
    // ------------------------------------------------------------------------
    function owner() public view returns (address) {
        return data.owner;
    }
    function newOwner() public view returns (address) {
        return data.newOwner;
    }
    function transferOwnership(address _newOwner) public {
        data.transferOwnership(_newOwner);
    }
    function acceptOwnership() public {
        data.acceptOwnership();
    }
    function transferOwnershipImmediately(address _newOwner) public {
        data.transferOwnershipImmediately(_newOwner);
    }

    // ------------------------------------------------------------------------
    // Token
    // ------------------------------------------------------------------------
    function symbol() public view returns (string) {
        return data.symbol;
    }
    function name() public view returns (string) {
        return data.name;
    }
    function decimals() public view returns (uint8) {
        return data.decimals;
    }

    // ------------------------------------------------------------------------
    // Minting and management
    // ------------------------------------------------------------------------
    function minter() public view returns (address) {
        return data.minter;
    }
    function setMinter(address _minter) public {
        data.setMinter(_minter);
    }
    function mint(address tokenOwner, uint tokens, bool lockAccount) public returns (bool success) {
        return data.mint(tokenOwner, tokens, lockAccount);
    }
    function accountLocked(address tokenOwner) public view returns (bool) {
        return data.accountLocked[tokenOwner];
    }
    function unlockAccount(address tokenOwner) public {
        data.unlockAccount(tokenOwner);
    }
    function mintable() public view returns (bool) {
        return data.mintable;
    }
    function transferable() public view returns (bool) {
        return data.transferable;
    }
    function disableMinting() public {
        data.disableMinting();
    }
    function enableTransfers() public {
        data.enableTransfers();
    }
    function nextNonce(address spender) public view returns (uint) {
        return data.nextNonce[spender];
    }

    // ------------------------------------------------------------------------
    // Other functions
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public returns (bool success) {
        return data.transferAnyERC20Token(tokenAddress, tokens);
    }

    // ------------------------------------------------------------------------
    // Don't accept ethers
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }

    // ------------------------------------------------------------------------
    // Token functions
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return data.totalSupply - data.balances[address(0)];
    }
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return data.balances[tokenOwner];
    }
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return data.allowed[tokenOwner][spender];
    }
    function transfer(address to, uint tokens) public returns (bool success) {
        return data.transfer(to, tokens);
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        return data.approve(spender, tokens);
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        return data.transferFrom(from, to, tokens);
    }
    function approveAndCall(address spender, uint tokens, bytes _data) public returns (bool success) {
        return data.approveAndCall(spender, tokens, _data);
    }

    // ------------------------------------------------------------------------
    // Signed function
    // ------------------------------------------------------------------------
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        return data.signedTransferHash(tokenOwner, to, tokens, fee, nonce);
    }
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result) {
        return data.signedTransferCheck(tokenOwner, to, tokens, fee, nonce, sig, feeAccount);
    }
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        return data.signedTransfer(tokenOwner, to, tokens, fee, nonce, sig, feeAccount);
    }
    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        return data.signedApproveHash(tokenOwner, spender, tokens, fee, nonce);
    }
    function signedApproveCheck(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result) {
        return data.signedApproveCheck(tokenOwner, spender, tokens, fee, nonce, sig, feeAccount);
    }
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        return data.signedApprove(tokenOwner, spender, tokens, fee, nonce, sig, feeAccount);
    }
    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash) {
        return data.signedTransferFromHash(spender, from, to, tokens, fee, nonce);
    }
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result) {
        return data.signedTransferFromCheck(spender, from, to, tokens, fee, nonce, sig, feeAccount);
    }
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        return data.signedTransferFrom(spender, from, to, tokens, fee, nonce, sig, feeAccount);
    }
    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce) public view returns (bytes32 hash) {
        return data.signedApproveAndCallHash(tokenOwner, spender, tokens, _data, fee, nonce);
    }
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result) {
        return data.signedApproveAndCallCheck(tokenOwner, spender, tokens, _data, fee, nonce, sig, feeAccount);
    }
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success) {
        return data.signedApproveAndCall(tokenOwner, spender, tokens, _data, fee, nonce, sig, feeAccount);
    }
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
    function transferOwnershipImmediately(address _newOwner) public onlyOwner {
        OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Token Factory v1.10
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------
contract BTTSTokenFactory is Owned {

    // ------------------------------------------------------------------------
    // Internal data
    // ------------------------------------------------------------------------
    mapping(address => bool) _verify;
    address[] public deployedTokens;

    // ------------------------------------------------------------------------
    // Event
    // ------------------------------------------------------------------------
    event BTTSTokenListing(address indexed ownerAddress,
        address indexed bttsTokenAddress,
        string symbol, string name, uint8 decimals,
        uint initialSupply, bool mintable, bool transferable);


    // ------------------------------------------------------------------------
    // Anyone can call this method to verify whether the bttsToken contract at
    // the specified address was deployed using this factory
    //
    // Parameters:
    //   tokenContract  the bttsToken contract address
    //
    // Return values:
    //   valid          did this BTTSTokenFactory create the BTTSToken contract?
    //   decimals       number of decimal places for the token contract
    //   initialSupply  the token initial supply
    //   mintable       is the token mintable after deployment?
    //   transferable   are the tokens transferable after deployment?
    // ------------------------------------------------------------------------
    function verify(address tokenContract) public view returns (
        bool    valid,
        address owner,
        uint    decimals,
        bool    mintable,
        bool    transferable
    ) {
        valid = _verify[tokenContract];
        if (valid) {
            BTTSToken t = BTTSToken(tokenContract);
            owner        = t.owner();
            decimals     = t.decimals();
            mintable     = t.mintable();
            transferable = t.transferable();
        }
    }


    // ------------------------------------------------------------------------
    // Any account can call this method to deploy a new BTTSToken contract.
    // The owner of the BTTSToken contract will be the calling account
    //
    // Parameters:
    //   symbol         symbol
    //   name           name
    //   decimals       number of decimal places for the token contract
    //   initialSupply  the token initial supply
    //   mintable       is the token mintable after deployment?
    //   transferable   are the tokens transferable after deployment?
    //
    // For example, deploying a BTTSToken contract with `initialSupply` of
    // 1,000.000000000000000000 tokens:
    //   symbol         "ME"
    //   name           "My Token"
    //   decimals       18
    //   initialSupply  10000000000000000000000 = 1,000.000000000000000000
    //                  tokens
    //   mintable       can tokens be minted after deployment?
    //   transferable   are the tokens transferable after deployment?
    //
    // The BTTSTokenListing() event is logged with the following parameters
    //   owner          the account that execute this transaction
    //   symbol         symbol
    //   name           name
    //   decimals       number of decimal places for the token contract
    //   initialSupply  the token initial supply
    //   mintable       can tokens be minted after deployment?
    //   transferable   are the tokens transferable after deployment?
    // ------------------------------------------------------------------------
    function deployBTTSTokenContract(
        string symbol,
        string name,
        uint8 decimals,
        uint initialSupply,
        bool mintable,
        bool transferable
    ) public returns (address bttsTokenAddress) {
        bttsTokenAddress = new BTTSToken(
            msg.sender,
            symbol,
            name,
            decimals,
            initialSupply,
            mintable,
            transferable);
        // Record that this factory created the trader
        _verify[bttsTokenAddress] = true;
        deployedTokens.push(bttsTokenAddress);
        BTTSTokenListing(msg.sender, bttsTokenAddress, symbol, name, decimals,
            initialSupply, mintable, transferable);
    }


    // ------------------------------------------------------------------------
    // Number of deployed tokens
    // ------------------------------------------------------------------------
    function numberOfDeployedTokens() public view returns (uint) {
        return deployedTokens.length;
    }

    // ------------------------------------------------------------------------
    // Factory owner can transfer out any accidentally sent ERC20 tokens
    //
    // Parameters:
    //   tokenAddress  contract address of the token contract being withdrawn
    //                 from
    //   tokens        number of tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

    // ------------------------------------------------------------------------
    // Don't accept ethers
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}