pragma solidity >=0.8.10 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DraupMembershipERC721.sol";

contract DraupMembershipERC721MintTest is Test {
    DraupMembershipERC721 public draupMembershipERC721;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    address private owner = vm.addr(uint256(keccak256(abi.encodePacked("owner"))));
    address private minter = vm.addr(uint256(keccak256(abi.encodePacked("minter"))));
    bytes32 private merkleRoot = hex'e58156f1fe47b87b38d2fc90dd2ed37c2ed80c4833b46ef37fd6c10b4f15fadd';
    bytes32[] private merkleProof = new bytes32[](3);

    function setUp() public {
        // transfer lock only works after lockup period number of blocks
        vm.roll(1_000_000);
        draupMembershipERC721 = new DraupMembershipERC721(3, 'https://assets.draup.xyz/member_pass/metadata/member_pass_');
        draupMembershipERC721.transferOwnership(owner);
        vm.deal(owner, 100 ether);
        vm.deal(minter, 100 ether);
        vm.prank(owner);
        draupMembershipERC721.setMerkleRoot(merkleRoot);
        merkleProof[0] = hex'61608fc4a22e50bb7145b85c74b673404fdd82a4b05c5f176f36a092209a204d';
        merkleProof[1] = hex'b83b0d782919b4ecc6cb4f744339823754ed3d3e980cdf8204194bfa6bab1de8';
        merkleProof[2] = hex'e1196e36db67e723e3b325b53c9f124eb38460ed3c1e0b6a7b501cf9478f6ab0';
    }

    function testMintBlocksInvalidMerkleProof() public {
        merkleProof[1] = bytes32('med3af');
        vm.startPrank(minter);
        vm.expectRevert(abi.encodeWithSelector(DraupMembershipERC721.InvalidProof.selector));
        draupMembershipERC721.mint(merkleProof);
    }

    function testMintAllowsValidMerkleProof() public {
        vm.startPrank(minter);
        draupMembershipERC721.mint(merkleProof);
        uint256 newBalance = draupMembershipERC721.balanceOf(minter);
        assertEq(newBalance, 1);
    }

    function testMintEmitsTransferEvent() public {
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0x0), minter, 1);
        vm.startPrank(minter);
        draupMembershipERC721.mint(merkleProof);
    }

    function testMintPreventsReuseOfAllowListSpot() public {
        vm.startPrank(minter);
        draupMembershipERC721.mint(merkleProof);
        assertEq(draupMembershipERC721.balanceOf(minter), 1);
        vm.expectRevert(abi.encodeWithSelector(DraupMembershipERC721.AlreadyClaimed.selector));
        draupMembershipERC721.mint(merkleProof);
        assertEq(draupMembershipERC721.balanceOf(minter), 1);
    }

    function testMintEnforcesMaxSupply() public {
        vm.prank(minter);
        draupMembershipERC721.mint(merkleProof);
        assertEq(draupMembershipERC721.balanceOf(minter), 1);

        bytes32[] memory merkleProof2 = new bytes32[](3);
        merkleProof2[0] = hex'ce2a1c7ad2ecd21292712125572dbf45469a8a17e97ee5df84a979c27431f821';
        merkleProof2[1] = hex'51fcda79b3a1efd6cf8c6be0355df88c087b64f2d7f08f36bfd5c5bc8e2f0c1d';
        merkleProof2[2] = hex'aea4e2c42c0bec286e9a3b90e5f337331c23b7a158e838038f6b2c4de88eb50d';
        address minter2 = 0x502367Ea6eA7ED256A55Ff70340EB81bF0e11bC2;
        assertEq(draupMembershipERC721.balanceOf(minter2), 0);
        vm.prank(minter2);
        draupMembershipERC721.mint(merkleProof2);
        assertEq(draupMembershipERC721.balanceOf(minter2), 1);

        bytes32[] memory merkleProof3 = new bytes32[](4);
        merkleProof3[0] = hex'1923097628a36e51f03a2196e0b91614442aa6844c9cbd2aac56914835894b4e';
        merkleProof3[1] = hex'e9fdd8d56b410fe043799357d2c736f9da17eafab2cd1c0111528ba6310e6199';
        merkleProof3[2] = hex'51fcda79b3a1efd6cf8c6be0355df88c087b64f2d7f08f36bfd5c5bc8e2f0c1d';
        merkleProof3[3] = hex'aea4e2c42c0bec286e9a3b90e5f337331c23b7a158e838038f6b2c4de88eb50d';
        address minter3 = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        assertEq(draupMembershipERC721.balanceOf(minter3), 0);
        vm.prank(minter3);
        draupMembershipERC721.mint(merkleProof3);
        assertEq(draupMembershipERC721.balanceOf(minter3), 1);

        bytes32[] memory merkleProof4 = new bytes32[](3);
        merkleProof4[0] = hex'3be05f1396a9c1aac2b6797bd9c8bd76f18a37def13aa204b570137c98024483';
        merkleProof4[1] = hex'b83b0d782919b4ecc6cb4f744339823754ed3d3e980cdf8204194bfa6bab1de8';
        merkleProof4[2] = hex'e1196e36db67e723e3b325b53c9f124eb38460ed3c1e0b6a7b501cf9478f6ab0';
        address minter4 = 0x9a66644084108a1bC23A9cCd50d6d63E53098dB6;
        assertEq(draupMembershipERC721.balanceOf(minter4), 0);
        vm.prank(minter4);
        vm.expectRevert(abi.encodeWithSelector(DraupMembershipERC721.MaxSupplyReached.selector));
        draupMembershipERC721.mint(merkleProof4);
        assertEq(draupMembershipERC721.balanceOf(minter4), 0);
    }
}