// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TradeableERC721Token.sol";

/**
 * @title LandCore
 * LandCore - a contract for 721Land's non-fungible creatures.
 */
contract LandCore is TradeableERC721Token {
    constructor(address _proxyRegistryAddress, address _privilege) TradeableERC721Token("721Land", "LAD", "https://api.721.land/main/nft/", _proxyRegistryAddress) {
        privilege = _privilege;
    }
    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;
    
    address public mintController;
    
     address privilege;
     
     https://api.721.land/main/nft/1
    
    function setPrivilege(address _privilege) public onlyOwner {
        privilege = _privilege;
    }
    
    modifier onlyPrivilege() {
        require(msg.sender == privilege);
        _;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // If token URI is set, return the token URI.
        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    
    function selfMint(address to, uint256 tokenId, string memory _tokenURI) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId));
        _mint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }
    
    function setMintController(address controller) public onlyOwner {
        mintController = controller;
    }
    
    function customMint(uint256 toBlockNumber, uint256 tokenId, string memory _tokenURI, bytes32 r, bytes32 s, uint8 v) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId));
        uint32 height = uint32(toBlockNumber);
        require(height >= block.number, "this data is expired");
        require(isApprovedToMint(toBlockNumber, tokenId, r, s, v), "the address is not approved to mint this nft");
        address from = address(uint160(tokenId >> 96));
        _mint(from, tokenId);
        address to = address(uint160(toBlockNumber >> 96));
        _transfer(from, to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }
    
    function isApprovedToMint(uint256 toBlockNumber, uint256 tokenId, bytes32 r, bytes32 s, uint8 v) internal view returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(toBlockNumber, tokenId));
        return ecrecover(hash, v, r, s) == mintController;
    }
    
    function multiMint(address[50] memory addrs, uint256 tokenId) public onlyPrivilege {
        for (uint i = 0; i < 50; i ++) {
            if (addrs[i] == address(0)){
                break;
            }
            singleMint(addrs[i], tokenId + i + 1);
        }
    }
    
    function singleMint(address addr, uint256 tokenId) public onlyPrivilege {
        _mint(addr, tokenId);
    }
}