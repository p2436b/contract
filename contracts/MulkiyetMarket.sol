// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MulkiyetMarket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MulkiyetMarket", "MM") {}

    function createNFT(string calldata tokenUri) public returns (uint) {
        _tokenIds.increment();
        _safeMint(msg.sender, _tokenIds.current());
        _setTokenURI(_tokenIds.current(), tokenUri);
        return _tokenIds.current();
    }
}
