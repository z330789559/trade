// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ERC721PresetMinterAutoId.sol";
import "../proxy/ProxyRegistry.sol";

/**
 * @title TradeableERC721Token
 * TradeableERC721Token - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
abstract contract TradeableERC721Token is ERC721PresetMinterAutoId, Ownable {
    using Strings for string;

    address proxyRegistryAddress;

    constructor(string memory _name, string memory _symbol, string memory _baseTokenURI, address _proxyRegistryAddress) ERC721PresetMinterAutoId(_name, _symbol, _baseTokenURI) {
        setProxyRegistryAddress(_proxyRegistryAddress);
    }

    function setProxyRegistryAddress(address _proxyRegistryAddress) public onlyOwner {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    /**
      * @dev calculates the next token ID based on totalSupply
      * @return uint256 for the next token ID
      */
    function _getNextTokenId() internal view returns (uint256) {
        return totalSupply() + 1;
    }
    
    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(
        address owner,
        address operator
    )
    public
    view
    override
    returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}