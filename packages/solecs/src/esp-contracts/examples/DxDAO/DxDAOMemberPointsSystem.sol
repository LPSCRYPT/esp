// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { IComponent } from "../../../interfaces/IComponent.sol";
import { ISystem } from "../../../interfaces/ISystem.sol";
import { IWorld } from "../../../interfaces/IWorld.sol";

import { System } from "../../../System.sol";

//ESP Core
import { ISignalRouterSystem } from "../../interfaces/ISignalRouterSystem.sol";

// DxDAO
import { DxDAOMemberPointsRegistry } from "./DxDAOMemberPointsRegistry.sol";
import { IDxDAOSignalStoreComponent } from "./interfaces/IDxDAOSignalStoreComponent.sol";
import { IDxDAOMemberAvailablePointsComponent } from "./interfaces/IDxDAOMemberAvailablePointsComponent.sol";
import { UserPoints } from "./lib/UserPoints.sol";

contract DxDAOMemberPointsSystem is System {
  address immutable store;
  address immutable available;

  ISystem immutable router;
  ISignalRouterSystem immutable routerStream;
  DxDAOMemberPointsRegistry immutable registry;

  constructor(
    address _router,
    address _registry,
    address _DxDAOSignalStoreComponent,
    address _DxDAOMemberAvailablePointsComponent,
    IWorld _world,
    address _components
  ) System(_world, address(0)) {
    store = _DxDAOSignalStoreComponent;
    /**@dev use indexer instead? */
    available = _DxDAOMemberAvailablePointsComponent;
    router = ISystem(_router);
    routerStream = ISignalRouterSystem(_router);
    registry = DxDAOMemberPointsRegistry(_registry);
  }

  // do relevant math for determining user points, and update the signal specified accordingly
  // component to request update on is DxDAOSignalStoreComponent
  function execute(bytes memory arguments) public override returns (bytes memory) {
    (uint256 points, string memory signal, bool add) = abi.decode(arguments, (uint256, string, bool));
    uint256 stream = routerStream.viewStreamCall();
    /**@dev replace with interface */
    require(points != 0, "Cannot signal with 0 points");
    uint256 totalPoints = registry.getUserPoints(stream, tx.origin);
    require(totalPoints >= points, "Request to edit more points than user has total");

    // add or remove points

    UserPoints memory returnArg = IDxDAOSignalStoreComponent(store).getValue(
      uint256(keccak256(abi.encode(stream, abi.encode(tx.origin, signal))))
    );

    uint256 availablePoints = IDxDAOMemberAvailablePointsComponent(available).getValue(
      uint256(keccak256(abi.encode(stream, abi.encode(tx.origin))))
    );

    if (add) {
      // add points at signal string
      require(availablePoints >= points, "Cannot signal more than available points");
      /**@dev add safe math at some point */
      returnArg.pointsString += points;
      if (returnArg.user == address(0)) {
        // if struct is uninitialized, initialize
        returnArg.user = tx.origin;
        returnArg.signal = signal;
        returnArg.stream = stream;
        returnArg.totalPoints = totalPoints;
      }
      // remove from available
      availablePoints -= points;
    } else {
      // remove points at signal string
      require(returnArg.pointsString >= points, "Cannot withdraw more points than signalled");
      returnArg.pointsString -= points;
      // add to available
      availablePoints += points;
    }
    router.execute(abi.encode(store, abi.encode(tx.origin, signal), abi.encode(returnArg)));
    router.execute(abi.encode(available, abi.encode((availablePoints))));
  }
}
