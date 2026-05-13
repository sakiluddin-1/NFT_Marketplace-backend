// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/BasicNFT.sol";
import "../src/NFTMarketplace.sol";

contract NftMarketplaceTest is Test {
    BasicNFT nft;
    NftMarketplace marketplace;

    address seller = address(1);
    address buyer = address(2);

    uint256 constant PRICE = 1 ether;

    function setUp() public {
        nft = new BasicNFT(10000, "");
        marketplace = new NftMarketplace();

        vm.deal(seller, 10 ether);
        vm.deal(buyer, 10 ether);

        vm.prank(seller);
        nft.mintNFT("ipfs://test");
    }

    function testListItem() public {
        uint256 tokenId = 0;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);

        marketplace.listItem(address(nft), tokenId, PRICE);
        vm.stopPrank();

        NftMarketplace.Listing memory listing =
    marketplace.getListing(address(nft), tokenId);

    uint256 price = listing.price;
    address listingSeller = listing.seller;

        assertEq(price, PRICE);
        assertEq(listingSeller, seller);
    }

    function testRevertIfPriceZero() public {
        uint256 tokenId = 0;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);

        vm.expectRevert("Price must be > 0");
        marketplace.listItem(address(nft), tokenId, 0);
        vm.stopPrank();
    }

    function testRevertIfAlreadyListed() public {
        uint256 tokenId = 0;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);

        marketplace.listItem(address(nft), tokenId, PRICE);

        vm.expectRevert("Already listed");
        marketplace.listItem(address(nft), tokenId, PRICE);

        vm.stopPrank();
    }

    function testRevertIfNotOwner() public {
        uint256 tokenId = 0;

        vm.expectRevert("Not owner");
        marketplace.listItem(address(nft), tokenId, PRICE);
    }

    function testRevertIfNotApproved() public {
        uint256 tokenId = 0;

        vm.prank(seller);

        vm.expectRevert("Not approved");
        marketplace.listItem(address(nft), tokenId, PRICE);
    }

    function testBuyItem() public {
        uint256 tokenId = 0;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.listItem(address(nft), tokenId, PRICE);
        vm.stopPrank();

        vm.prank(buyer);
        marketplace.buyItem{value: PRICE}(address(nft), tokenId);

        assertEq(nft.ownerOf(tokenId), buyer);
    }

    function testRevertIfNotListed() public {
        uint256 tokenId = 0;

        vm.prank(buyer);

        vm.expectRevert("Not listed");
        marketplace.buyItem{value: PRICE}(address(nft), tokenId);
    }

    function testRevertIfWrongPrice() public {
        uint256 tokenId = 0;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.listItem(address(nft), tokenId, PRICE);
        vm.stopPrank();

        vm.prank(buyer);

        vm.expectRevert("Price mismatch");
        marketplace.buyItem{value: 0.5 ether}(address(nft), tokenId);
    }

    function testCancelListing() public {
        uint256 tokenId = 0;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.listItem(address(nft), tokenId, PRICE);

        marketplace.cancelListing(address(nft), tokenId);
        vm.stopPrank();

        NftMarketplace.Listing memory listing =
    marketplace.getListing(address(nft), tokenId);

    uint256 price = listing.price;

        assertEq(price, 0);
    }

    function testRevertCancelIfNotOwner() public {
        uint256 tokenId = 0;

        vm.startPrank(seller);
        nft.approve(address(marketplace), tokenId);
        marketplace.listItem(address(nft), tokenId, PRICE);
        vm.stopPrank();

        vm.prank(buyer);

        vm.expectRevert("Not owner");
        marketplace.cancelListing(address(nft), tokenId);
    }
}