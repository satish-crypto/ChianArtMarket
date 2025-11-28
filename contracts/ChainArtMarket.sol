// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ChainArt Market - A decentralized marketplace for digital art NFTs
/// @author
contract ChainArtMarket {
    struct Art {
        uint256 id;
        string title;
        string uri;
        address payable creator;
        address payable owner;
        uint256 price;
        bool forSale;
    }

    uint256 public artCount;
    mapping(uint256 => Art) public arts;
    mapping(address => uint256[]) public ownerToArtIds;

    event ArtMinted(uint256 indexed id, address indexed creator, string title, string uri, uint256 price);
    event ArtListed(uint256 indexed id, uint256 price);
    event ArtUnlisted(uint256 indexed id);
    event ArtPurchased(uint256 indexed id, address indexed buyer, uint256 price);

    function mintArt(string memory _title, string memory _uri, uint256 _price) external {
        require(bytes(_title).length > 0, "Title required");
        require(bytes(_uri).length > 0, "URI required");
        require(_price > 0, "Price must be positive");

        artCount++;
        arts[artCount] = Art(
            artCount,
            _title,
            _uri,
            payable(msg.sender),
            payable(msg.sender),
            _price,
            true
        );
        ownerToArtIds[msg.sender].push(artCount);
        emit ArtMinted(artCount, msg.sender, _title, _uri, _price);
    }

    function listArt(uint256 _id, uint256 _price) external {
        Art storage art = arts[_id];
        require(msg.sender == art.owner, "Not art owner");
        require(_price > 0, "Invalid price");
        art.price = _price;
        art.forSale = true;
        emit ArtListed(_id, _price);
    }

    function unlistArt(uint256 _id) external {
        Art storage art = arts[_id];
        require(msg.sender == art.owner, "Not art owner");
        art.forSale = false;
        emit ArtUnlisted(_id);
    }

    function buyArt(uint256 _id) external payable {
        Art storage art = arts[_id];
        require(art.forSale, "Not for sale");
        require(msg.value == art.price, "Incorrect price");
        require(msg.sender != art.owner, "Cannot buy your own art");

        // Pay previous owner
        art.owner.transfer(msg.value);

        address prevOwner = art.owner;
        uint256[] storage prevOwnerArts = ownerToArtIds[prevOwner];

        // Transfer ownership
        art.owner = payable(msg.sender);
        art.forSale = false;

        // Remove art from previous owner's array and add to new owner
        for (uint256 i = 0; i < prevOwnerArts.length; i++) {
            if (prevOwnerArts[i] == _id) {
                prevOwnerArts[i] = prevOwnerArts[prevOwnerArts.length - 1];
                prevOwnerArts.pop();
                break;
            }
        }
        ownerToArtIds[msg.sender].push(_id);

        emit ArtPurchased(_id, msg.sender, msg.value);
    }

    function getMyArts() external view returns (uint256[] memory) {
        return ownerToArtIds[msg.sender];
    }

    function getArt(uint256 _id) external view returns (
        uint256 id,
        string memory title,
        string memory uri,
        address creator,
        address owner,
        uint256 price,
        bool forSale
    ) {
        Art storage art = arts[_id];
        return (art.id, art.title, art.uri, art.creator, art.owner, art.price, art.forSale);
    }
}
