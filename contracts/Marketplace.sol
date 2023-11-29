// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MulkiyetMarket is ERC721, Ownable {
    struct SharedOwner {
        address owner;
        uint256 sharePercentage;
    }

    struct Token {
        SharedOwner[] sharedOwners;
        mapping(address => uint256) ownerToIndex;
    }

    mapping(uint256 => Token) private tokens;

    event SharedOwnershipAdded(
        uint256 indexed tokenId,
        address indexed newOwner,
        uint256 sharePercentage
    );
    event SharedOwnershipRemoved(
        uint256 indexed tokenId,
        address indexed removedOwner
    );

    constructor() ERC721("Mulkiyet Market", "MM") Ownable() {}

    function mint(
        address[] memory _owners,
        uint256[] memory _percentages,
        uint256 _tokenId
    ) external onlyOwner {
        require(
            _owners.length == _percentages.length,
            "Array lengths don't match"
        );

        Token storage token = tokens[_tokenId];
        uint256 totalPercentage;

        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner address");
            require(
                _percentages[i] > 0 && _percentages[i] <= 100,
                "Invalid percentage"
            );

            token.sharedOwners.push(SharedOwner(_owners[i], _percentages[i]));
            token.ownerToIndex[_owners[i]] = i;
            totalPercentage += _percentages[i];
        }

        require(totalPercentage == 100, "Total percentage must be 100");

        _safeMint(msg.sender, _tokenId);
    }

    function addSharedOwner(
        uint256 _tokenId,
        address _newOwner,
        uint256 _newPercentage
    ) external onlyOwner {
        Token storage token = tokens[_tokenId];
        require(token.ownerToIndex[_newOwner] == 0, "Owner already exists");

        token.sharedOwners.push(SharedOwner(_newOwner, _newPercentage));
        token.ownerToIndex[_newOwner] = token.sharedOwners.length;

        emit SharedOwnershipAdded(_tokenId, _newOwner, _newPercentage);
    }

    function removeSharedOwner(
        uint256 _tokenId,
        address _ownerToRemove
    ) external onlyOwner {
        Token storage token = tokens[_tokenId];
        require(
            token.ownerToIndex[_ownerToRemove] != 0,
            "Owner does not exist"
        );

        uint256 index = token.ownerToIndex[_ownerToRemove] - 1;
        delete token.sharedOwners[index];
        token.ownerToIndex[_ownerToRemove] = 0;

        emit SharedOwnershipRemoved(_tokenId, _ownerToRemove);
    }

    function getTokenSharedOwners(
        uint256 _tokenId
    ) external view returns (SharedOwner[] memory) {
        return tokens[_tokenId].sharedOwners;
    }

    function transferShare(
        uint256 _tokenId,
        address _from,
        address _to,
        uint256 _percentage
    ) external onlyOwner {
        require(_from != _to, "Cannot transfer share to the same owner");
        require(_percentage > 0 && _percentage <= 100, "Invalid percentage");

        Token storage token = tokens[_tokenId];
        require(token.ownerToIndex[_from] != 0, "Sender owner does not exist");
        require(token.ownerToIndex[_to] == 0, "Recipient owner already exists");

        uint256 fromIndex = token.ownerToIndex[_from] - 1;
        require(
            token.sharedOwners[fromIndex].sharePercentage >= _percentage,
            "Insufficient share to transfer"
        );

        token.sharedOwners[fromIndex].sharePercentage -= _percentage;

        if (token.sharedOwners[fromIndex].sharePercentage == 0) {
            delete token.sharedOwners[fromIndex];
            token.ownerToIndex[_from] = 0;
        }

        token.sharedOwners.push(SharedOwner(_to, _percentage));
        token.ownerToIndex[_to] = token.sharedOwners.length;

        emit SharedOwnershipAdded(_tokenId, _to, _percentage);
        emit SharedOwnershipRemoved(_tokenId, _from);
    }
}
