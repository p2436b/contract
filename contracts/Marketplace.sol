// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address public owner;

    struct MarketItem {
        uint itemId;
        uint tokenId;
        uint price;
        address nftContract;
        address payable seller;
        address payable owner;
        bool sold;
    }

    event MarketItemCreated(
        uint indexed itemId,
        uint indexed tokenId,
        uint price,
        address indexed nftContract,
        address seller,
        address owner,
        bool sold
    );

    mapping(uint => MarketItem) private idToMarketItem;

    constructor() {
        owner == msg.sender;
    }

    function createMarketItem(
        address nftContract,
        uint tokenId,
        uint price
    ) public payable nonReentrant {
        require(price > 0, "Price must be greater than 0");

        _itemIds.increment();
        uint itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            tokenId,
            price,
            nftContract,
            payable(msg.sender),
            payable(address(0)),
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            tokenId,
            price,
            nftContract,
            msg.sender,
            address(0),
            false
        );
    }
}
