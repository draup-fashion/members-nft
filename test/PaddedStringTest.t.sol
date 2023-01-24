pragma solidity >=0.8.10 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {PaddedString} from "../src/PaddedString.sol";

contract PadStringUtilTest is Test {
    function bytes32ToString(bytes32 x) public pure returns (string memory value) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            bytes1 char = bytes1(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        value = string(bytesStringTrimmed);
    }
    function testPaddedZero() public {
        string memory value = PaddedString.digitsToString(9, 0);
        string memory expected = "";
        assertEq(bytes32ToString(bytes32(abi.encode(value))), bytes32ToString(bytes32(abi.encode(expected))));
    }
    function testPaddedOne() public {
        string memory value = PaddedString.digitsToString(9, 1);
        string memory expected = "9";
        assertEq(bytes32ToString(bytes32(abi.encode(value))), bytes32ToString(bytes32(abi.encode(expected))));
    }
    function testPaddedTwo() public {
        string memory value = PaddedString.digitsToString(1, 2);
        string memory expected = "01";
        assertEq(bytes32ToString(bytes32(abi.encode(value))), bytes32ToString(bytes32(abi.encode(expected))));
    }
    function testPaddedThree() public {
        string memory value = PaddedString.digitsToString(2, 3);
        string memory expected = "002";
        assertEq(bytes32ToString(bytes32(abi.encode(value))), bytes32ToString(bytes32(abi.encode(expected))));
    }
    function testPaddedFour() public {
        string memory value = PaddedString.digitsToString(5, 3);
        string memory expected = "0005";
        assertEq(bytes32ToString(bytes32(abi.encode(value))), bytes32ToString(bytes32(abi.encode(expected))));
    }
    function testPaddedFive() public {
        string memory value = PaddedString.digitsToString(7, 3);
        string memory expected = "00007";
        assertEq(bytes32ToString(bytes32(abi.encode(value))), bytes32ToString(bytes32(abi.encode(expected))));
    }
}