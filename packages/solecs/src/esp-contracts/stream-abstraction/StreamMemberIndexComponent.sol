// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { BareComponent } from "../../BareComponent.sol";
import { LibTypes } from "../../LibTypes.sol";

/**
@notice A mapping of uint256 streamIDs => address of a MemberRegistrySystem 
@notice The MemberRegistrySystem takes care of all logic for determining if a particular user is valid
 */

contract StreamMemberIndexComponent is BareComponent {
  constructor(address world, uint256 id) BareComponent(world, id) {}

  function getValue(uint256 entity) public view returns (address) {
    bytes memory rawValue = getRawValue(entity);
    if (rawValue.length > 0) {
      return abi.decode(rawValue, (address));
    } else {
      return address(0);
    }
  }

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "memberRegistrySystem";
    values[0] = LibTypes.SchemaValue.ADDRESS;
  }
}
