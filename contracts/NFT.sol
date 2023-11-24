// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MulkiyetMarket is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => address[]) private tokenSharedOwners;
    uint256 public constant maxShares = 100; // Max number of shares per NFT
    uint256 public constant maxTotalShares = 1000; // Max total shares allowed

    constructor() ERC721("MulkiyetMarket", "MM") {}

    function mintNFT(
        address recipient,
        string memory tokenURI
    ) public onlyOwner returns (uint) {
        _tokenIds.increment();
        uint tokenId = _tokenIds.current();
        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }

    function createNFT(string calldata tokenUri) public returns (uint) {
        _tokenIds.increment();
        _safeMint(msg.sender, _tokenIds.current());
        _setTokenURI(_tokenIds.current(), tokenUri);
        return _tokenIds.current();
    }
}
