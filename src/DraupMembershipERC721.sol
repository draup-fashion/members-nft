// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract DraupMembershipERC721 is ERC721, Ownable {

    constructor() ERC721("Draup Membership", "DRAUP") {}

    uint256 public nextTokenId;
    bytes32 public merkleRoot;
    string _BaseURI = "test";

    // Mapping to track who used their allowlist spot
    mapping(address => bool) public claimed;

    error InvalidProof();

    function toBytes32(address addr) pure internal returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function mint(bytes32[] calldata merkleProof) public {
        require(claimed[msg.sender] == false, "already claimed");
        claimed[msg.sender] = true;
        if (MerkleProof.verify(merkleProof, merkleRoot, toBytes32(msg.sender)) != true) {
            revert InvalidProof();
        }
        nextTokenId++;
        _mint(msg.sender, nextTokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _BaseURI;
    }

    function withdrawAll() external {
        require(address(this).balance > 0, "Zero balance");
        (bool sent, ) = owner().call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }

    function withdrawAllERC20(IERC20 token) external {
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}

