// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { IWorld } from "../../../interfaces/IWorld.sol";

// ESP Core
import { BaseMemberRegistrySystem } from "../../stream-abstraction/BaseMemberRegistrySystem.sol";

// DxDAO Core
import { DxDAOMemberPointsRegistry } from "./DxDAOMemberPointsRegistry.sol";

contract DxDAOMemberRegistrySystem is BaseMemberRegistrySystem {
  // address of the DxDAOMemberPointsRegistry to lookup member validity
  address registry;

  constructor(
    address _registry,
    IWorld _world,
    address _components
  ) BaseMemberRegistrySystem(_world, address(0)) {
    registry = _registry;
  }

  function execute(bytes memory arguments) public override returns (bytes memory) {
    (uint256 _stream, address _user) = abi.decode(arguments, (uint256, address));
    // lookup from component state of memberRegistry + points value
    // change to interface to save gas
    uint256 p = DxDAOMemberPointsRegistry(registry).getUserPoints(_stream, _user);
    if (p > 0) {
      return abi.encodePacked(true);
    } else {
      return abi.encodePacked(false);
    }
  }
}
