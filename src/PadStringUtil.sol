// SPDX-License-Identifier: MIT
// Adapted from OpenZeppelin's utils/Strings.sol
pragma solidity ^0.8.0;

/**
 * @dev Output numbers as padded strings.
 */
library PaddedString {
    bytes16 private constant _SYMBOLS = "0123456789";
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation with zero padding.
     * Length is total string length returned.
     */
    function digitsToString(uint256 value, uint256 length) internal pure returns (string memory) {
        unchecked {
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (length-- == 0) break;
            }
            return buffer;
        }
    }

}
