// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/** Expects packed encoding */
function decodeAddress(bytes memory _data) pure returns (address addr) {
  assembly {
    addr := mload(add(_data, 20))
  }
}
