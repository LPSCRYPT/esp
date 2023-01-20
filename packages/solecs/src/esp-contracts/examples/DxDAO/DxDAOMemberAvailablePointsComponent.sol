// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { Component } from "../../../Component.sol";
import { LibTypes } from "../../../LibTypes.sol";
import { UserPoints } from "./lib/UserPoints.sol";

// DxDAOCore
import { IDxDAOMemberAvailablePointsComponent } from "./interfaces/IDxDAOMemberAvailablePointsComponent.sol";

uint256 constant ID = uint256(keccak256("ESP.component.DxDAOMemberAvailablePointsComponent"));

contract DxDAOMemberAvailablePointsComponent is Component, IDxDAOMemberAvailablePointsComponent {
  constructor(address _router, address _world) Component(world, ID) {
    // Registers component update permissions to only the SignalRouterSystem
    authorizeWriter(_router);
    unauthorizeWriter(msg.sender);
  }

  function set(uint256 entity, uint256 value) public {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view returns (uint256) {
    return abi.decode(getRawValue(entity), (uint256));
  }

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "availablePoints";
    values[0] = LibTypes.SchemaValue.UINT256;
  }

  /**
    @dev Key Schema
    uint256(keccak256(bytes(stream, _args)))
    _args = (user(address))

    @dev Value Schema
    bytes(args)
    args = {availablepoints(uint256)}
     */
}
