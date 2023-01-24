// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC2981, IERC165} from "openzeppelin-contracts/contracts/interfaces/IERC2981.sol";
import {DefaultOperatorFilterer} from "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MerkleProof} from "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {PaddedString} from "./PadStringUtil.sol";
import {IRenderer} from "./IRenderer.sol";

contract DraupMembershipERC721 is ERC721, Ownable, DefaultOperatorFilterer {
    uint256 public immutable MAX_SUPPLY;
    uint256 public immutable ROYALTY = 7500;
    bool public TRANSFERS_ALLOWED = false;
    IRenderer public renderer;
    string public baseTokenURI;

    constructor(uint256 maxSupply, string memory baseURI) ERC721("Draup Membership", "DRAUP") {
        MAX_SUPPLY = maxSupply;
        baseTokenURI = baseURI;
    }

    uint256 public nextTokenId;
    bytes32 public merkleRoot;
    string _BaseURI = "test";

    // Mapping to track who used their allowlist spot
    mapping(address => bool) private _claimed;

    error InvalidProof();
    error AlreadyClaimed();
    error MaxSupplyReached();
    error TransfersNotAllowed();

    function mint(bytes32[] calldata merkleProof) public {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, 1))));
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert InvalidProof();
        }
        if (_claimed[msg.sender]) {
            revert AlreadyClaimed();
        }
        _claimed[msg.sender] = true;
        nextTokenId++;
        if (nextTokenId > MAX_SUPPLY) {
            revert MaxSupplyReached();
        }
        _mint(msg.sender, nextTokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        if (!TRANSFERS_ALLOWED && from != address(0)) {
            revert TransfersNotAllowed();
        }
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        _requireMinted(tokenId);
        if (address(renderer) != address(0)) {
            return renderer.tokenURI(tokenId);
        }
        return
            string(
                abi.encodePacked(
                    baseTokenURI,
                    PaddedString.digitsToString(tokenId, 3),
                    ".json"
                )
            );
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override
        returns (bool)
    {
        return
            _interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(_interfaceId);
    }

    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        returns (address, uint256)
    {
        return (address(this), (salePrice * ROYALTY) / 10000);
    }

    // Admin

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function enableTransfers() external onlyOwner {
        TRANSFERS_ALLOWED = true;
    }

    function setRenderer(IRenderer _renderer) external onlyOwner {
        renderer = _renderer;
    }

    function setBaseTokenURI(string calldata _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
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

