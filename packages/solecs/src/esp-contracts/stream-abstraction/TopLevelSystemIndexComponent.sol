// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { BareComponent } from "../../BareComponent.sol";
import { LibTypes } from "../../LibTypes.sol";

// ESP Core
import { decodeBool } from "../logic/DecodeBool.sol";

contract TopLevelSystemIndexComponent is BareComponent {
  constructor(address world, uint256 id) BareComponent(world, id) {}

  function getValue(uint256 entity) public view returns (bool) {
    bytes memory rawValue = getRawValue(entity);
    if (rawValue.length > 0) {
      return decodeBool(rawValue);
    } else {
      return false;
    }
  }

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "topLevelSystemAddress";
    values[0] = LibTypes.SchemaValue.ADDRESS;
  }
}
