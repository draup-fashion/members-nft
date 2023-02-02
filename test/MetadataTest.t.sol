pragma solidity >=0.8.10 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DraupMembershipERC721.sol";
import "../src/ExampleRenderer.sol";

contract DraupMembershipERC721MetadataTest is Test {
    DraupMembershipERC721 public draupMembershipERC721;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    address private owner = vm.addr(uint256(keccak256(abi.encodePacked("owner"))));
    address private minter = vm.addr(uint256(keccak256(abi.encodePacked("minter"))));
    address private recipient = vm.addr(uint256(keccak256(abi.encodePacked("recipient"))));
    bytes32 private merkleRoot = hex'e58156f1fe47b87b38d2fc90dd2ed37c2ed80c4833b46ef37fd6c10b4f15fadd';
    bytes32[] private merkleProof = new bytes32[](3);

    function setUp() public {
        // transfer lock only works after lockup period number of blocks
        vm.roll(1_000_000);
        draupMembershipERC721 = new DraupMembershipERC721(10, 'https://assets.draup.xyz/member_pass/metadata/member_pass_');
        draupMembershipERC721.transferOwnership(owner);
        vm.deal(owner, 100 ether);
        vm.deal(minter, 100 ether);
        vm.prank(owner);
        draupMembershipERC721.setMerkleRoot(merkleRoot);
        merkleProof[0] = hex'61608fc4a22e50bb7145b85c74b673404fdd82a4b05c5f176f36a092209a204d';
        merkleProof[1] = hex'b83b0d782919b4ecc6cb4f744339823754ed3d3e980cdf8204194bfa6bab1de8';
        merkleProof[2] = hex'e1196e36db67e723e3b325b53c9f124eb38460ed3c1e0b6a7b501cf9478f6ab0';
        vm.prank(minter);
        draupMembershipERC721.mint(merkleProof, address(0));
    }

    function testNoMetadataForUnmintedTokens() public {
        vm.expectRevert(bytes("ERC721: invalid token ID"));
        draupMembershipERC721.tokenURI(2);
    }

    function testMetadataURI() public {
        string memory uri1 = draupMembershipERC721.tokenURI(0);
        string memory uri1Test = string(
                abi.encodePacked(
                    draupMembershipERC721.baseTokenURI(),
                    PaddedString.digitsToString(0, 3),
                    ".json"
                )
            );
        assertEq(uri1, uri1Test);
    }

    function testNonOwnerCannotUpgradeRenderer() public {
        IRenderer renderer = new ExampleRenderer();
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        draupMembershipERC721.setRenderer(renderer);
    }

    function testUpgradeRenderer() public {
        assertEq(address(0), address(draupMembershipERC721.renderer()));
        IRenderer renderer = new ExampleRenderer();
        vm.prank(owner);
        draupMembershipERC721.setRenderer(renderer);
        assertEq(address(renderer), address(draupMembershipERC721.renderer()));
        string memory uri1 = draupMembershipERC721.tokenURI(0);
        assertEq(uri1, "https://www.example.com/0.json");
    }

}