pragma solidity >=0.8.10 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DraupMembershipERC721.sol";

contract DraupMembershipERC721AllowListTest is Test {
    DraupMembershipERC721 public draupMembershipERC721;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    address private owner = vm.addr(uint256(keccak256(abi.encodePacked("owner"))));
    address private minter = vm.addr(uint256(keccak256(abi.encodePacked("minter"))));
    bytes32 private merkleRoot = hex'e58156f1fe47b87b38d2fc90dd2ed37c2ed80c4833b46ef37fd6c10b4f15fadd';
    bytes32[] merkleProof = new bytes32[](3);

    function setUp() public {
        // transfer lock only works after lockup period number of blocks
        vm.roll(1_000_000);
        draupMembershipERC721 = new DraupMembershipERC721();
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

    function testMintPreventsMultipleUses() public {
        vm.startPrank(minter);
        draupMembershipERC721.mint(merkleProof);
        assertEq(draupMembershipERC721.balanceOf(minter), 1);
        vm.expectRevert(abi.encodeWithSelector(DraupMembershipERC721.AlreadyClaimed.selector));
        draupMembershipERC721.mint(merkleProof);
        assertEq(draupMembershipERC721.balanceOf(minter), 1);
    }

}