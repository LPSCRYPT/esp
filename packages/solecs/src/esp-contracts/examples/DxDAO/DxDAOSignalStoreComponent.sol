// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { Component } from "../../../Component.sol";
import { LibTypes } from "../../../LibTypes.sol";

// DxDAO
import { IDxDAOSignalStoreComponent } from "./interfaces/IDxDAOSignalStoreComponent.sol";
import { UserPoints } from "./lib/UserPoints.sol";

/**
@dev Stores data for a user(address)'s point balance(uint256) on a particular signal(string) in a stream(uint256)
 */

uint256 constant ID = uint256(keccak256("ESP.component.DxDAOSignalStore"));

contract DxDAOSignalStoreComponent is Component, IDxDAOSignalStoreComponent {
  constructor(address _router, address _world) Component(_world, ID) {
    // Registers component update permissions to only the SignalRouterSystem
    authorizeWriter(_router);
    unauthorizeWriter(msg.sender);
  }

  function set(uint256 entity, UserPoints calldata value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (UserPoints memory) {
    // Added check to return empty struct on uninitialized case
    bytes memory raw = getRawValue(entity);
    if (raw.length == 0) {
      UserPoints memory U;
      return U;
    } else {
      return abi.decode(getRawValue(entity), (UserPoints));
    }
  }

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](5);
    values = new LibTypes.SchemaValue[](5);

    keys[0] = "stream";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "user";
    values[1] = LibTypes.SchemaValue.ADDRESS;

    keys[2] = "signal";
    values[2] = LibTypes.SchemaValue.STRING;

    keys[3] = "pointsString";
    values[3] = LibTypes.SchemaValue.UINT256;

    keys[4] = "totalPoints";
    values[4] = LibTypes.SchemaValue.UINT256;
  }

  /**
    @dev Key Schema
    uint256(keccak256(bytes(stream, _args)))
    _args = (user(address), signal(string))

    @dev Value Schema
    bytes(args)
    args = {stream(uint256), user(address), signal(string), pointsString(uint256), totalpoints(uint256)}
     */
}
