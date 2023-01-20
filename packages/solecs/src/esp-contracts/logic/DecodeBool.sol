// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/** Expects packed encoding */
function decodeBool(bytes memory _data) pure returns (bool b) {
  assembly {
    // Load the length of data (first 32 bytes)
    let len := mload(_data)
    // Load the data after 32 bytes, so add 0x20
    b := mload(add(_data, 0x20))
  }
}
