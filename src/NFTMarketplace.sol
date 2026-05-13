// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract NftMarketplace is ReentrancyGuard {
    struct Listing {
        uint256 price;
        address seller;
    }

    mapping(address => mapping(uint256 => Listing)) private s_listings;

    function listItem(address nftAddress, uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be > 0");
        require(s_listings[nftAddress][tokenId].price == 0, "Already listed");

        IERC721 nft = IERC721(nftAddress);

        require(nft.ownerOf(tokenId) == msg.sender, "Not owner");
        require(
            nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "Not approved"
        );

        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
    }

    function buyItem(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory listing = s_listings[nftAddress][tokenId];

        require(listing.price > 0, "Not listed");
        require(msg.value == listing.price, "Price mismatch");

        delete s_listings[nftAddress][tokenId];

        IERC721(nftAddress).safeTransferFrom(listing.seller, msg.sender, tokenId);

        (bool success,) = payable(listing.seller).call{value: msg.value}("");
        require(success, "Payment failed");
    }

    function cancelListing(address nftAddress, uint256 tokenId) external {
        Listing memory listing = s_listings[nftAddress][tokenId];

        require(listing.price > 0, "Not listed");
        require(IERC721(nftAddress).ownerOf(tokenId) == msg.sender, "Not owner");

        delete s_listings[nftAddress][tokenId];
    }

    function getListing(address nftAddress, uint256 tokenId) public view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }
}
