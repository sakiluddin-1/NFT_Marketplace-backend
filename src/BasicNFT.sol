// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract BasicNFT is ERC721URIStorage {

    uint256 private _tokenIdCounter;
    string private _baseTokenURI;
    uint256 immutable public MAX_SUPPLY;

    constructor(uint256 _maxSupply, string memory baseTokenURI) ERC721("BasicNFT", "BNFT") {
        _tokenIdCounter = 0;
        MAX_SUPPLY = _maxSupply;
        _baseTokenURI = baseTokenURI;
    }

    function mintNFT(string memory tokenURI) public returns(uint256) {
        require(_tokenIdCounter < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = _tokenIdCounter;

        _safeMint(msg.sender, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter, tokenURI);

        _tokenIdCounter ++;

        return tokenId;
    }

    function getTokenCounter() public view returns(uint256) {
        return _tokenIdCounter;
    }
}