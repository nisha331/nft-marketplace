// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/SafeERC721.sol";


contract NFTMarketplace is ERC721URIStorage {

    using Counters for Counters.Counter;
    using SafeERC721 for IERC721;

    Counters.Counter private _tokenIds;
   
    Counters.Counter private _itemsSold;
    address payable owner;
   
    uint256 listPrice = 0.01 ether;

    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    event TokenListedSuccess (
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool currentlyListed
    );

    mapping(uint256 => ListedToken) private idToListedToken;

    constructor() ERC721("NFTMarketplace", "NFTM") {
        owner = payable(msg.sender);
    }

    function updateListPrice(uint256 _listPrice) public payable {
        require(owner == msg.sender, "Only owner can update listing price");
        listPrice = _listPrice;
    }

    function getListPrice() public view returns (uint256) {
        return listPrice;
    }

    function getLatestIdToListedToken() public view returns (ListedToken memory) {
        uint256 currentTokenId = _tokenIds.current();
        return idToListedToken[currentTokenId];
    }

    function getListedTokenForId(uint256 tokenId) public view returns (ListedToken memory) {
        return idToListedToken[tokenId];
    }

    function getCurrentToken() public view returns (uint256) {
        return _tokenIds.current();
    }

    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);

        _setTokenURI(newTokenId, tokenURI);

        createListedToken(newTokenId, price);

        return newTokenId;
    }

    function createListedToken(uint256 tokenId, uint256 price) private {
        require(msg.value == listPrice, "Hopefully sending the correct price");
        require(price > 0, "Make sure the price isn't negative");

        idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );

        _transfer(msg.sender, address(this), tokenId);
        emit TokenListedSuccess(
            tokenId,
            address(this),
            msg.sender,
            price,
            true
        );
    }
    
    function getAllNFTs() public view returns (ListedToken[] memory) {
        uint nftCount = _tokenIds.current();
        ListedToken[] memory tokens = new ListedToken[](nftCount);
        uint currentIndex = 0;
        uint currentId;
        
        for(uint i=0;i<nftCount;i++)
        {
            currentId = i + 1;
            ListedToken storage currentItem = idToListedToken[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return tokens;
    }
    
    function getMyNFTs() public view returns (ListedToken[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        uint currentId;
        for(uint i=0; i < totalItemCount; i++)
        {
            if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender){
                itemCount += 1;
            }
        }

        ListedToken[] memory items = new ListedToken[](itemCount);
        for(uint i=0; i < totalItemCount; i++) {
            if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender) {
                currentId = i+1;
                ListedToken storage currentItem = idToListedToken[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function executeSale(uint256 tokenId) public payable {
        uint price = idToListedToken[tokenId].price;
        address payable seller = idToListedToken[tokenId].seller;
        address payable buyer = payable(msg.sender);

        // Ensure the buyer submitted the correct payment
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        // Update the ListedToken details
        idToListedToken[tokenId].currentlyListed = false;
        idToListedToken[tokenId].seller = buyer;
        _itemsSold.increment();

        // Check if the buyer has approval to transfer the NFT
        require(IERC721(address(this)).getApproved(tokenId) == address(this), "Seller has not approved the sale");

        // Transfer ownership of the NFT
        IERC721(address(this)).transferFrom(seller, buyer, tokenId);

        // Set approval to address(0) to clear any existing approvals
        IERC721(address(this)).setApprovalForAll(address(0), false);

        // Transfer funds: subtract from buyer, add to seller
        (bool buyerTransferSuccess,) = buyer.call{value: price}("");
        require(buyerTransferSuccess, "Failed to transfer funds to the buyer");

        (bool sellerTransferSuccess,) = seller.call{value: listPrice}("");
        require(sellerTransferSuccess, "Failed to transfer funds to the seller");
    }

    function burn(uint256 tokenId) public {
        // Ensure that the caller is the owner of the token
        require(ownerOf(tokenId) == msg.sender, "You can only burn your own NFT");

        // Burn the NFT
        _burn(tokenId);
    }
}
