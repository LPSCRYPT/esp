// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
// import { Vm } from "forge-std/Vm.sol";
import { console } from "forge-std/console.sol";

// MUD Core
import { World } from "../../../../World.sol";

// ESP Core
import { SignalRouterSystem } from "../../../SignalRouterSystem.sol";
import { StreamOwnerRegistry } from "../../../stream-abstraction/StreamOwnerRegistry.sol";

// DxDAO Core
import { DxDAOMemberAvailablePointsComponent } from "../DxDAOMemberAvailablePointsComponent.sol";
import { DxDAOMemberPointsRegistry } from "../DxDAOMemberPointsRegistry.sol";
import { DxDAOMemberPointsSystem } from "../DxDAOMemberPointsSystem.sol";
import { DxDAOMemberRegistrySystem } from "../DxDAOMemberRegistrySystem.sol";
import { DxDAOSignalStoreComponent } from "../DxDAOSignalStoreComponent.sol";
import { UserPoints } from "../lib/UserPoints.sol";

contract DxDSignalScript is Script {
  // Vm internal immutable vm = Vm(HEVM_ADDRESS);

  function run() public {
    uint256 deployerPrivateKey = vm.envUint("GOERLI_PRIVATE_KEY_2");

    vm.startBroadcast(deployerPrivateKey);

    SignalRouterSystem router = SignalRouterSystem(0x44Fec79BaA6f6f9865bc61CB3566b56A57679A4e);

    router.execute(abi.encode(1, 0x1Ee7B1baAAC58b05c84EBE42aBFf6bDE5Aa504d9, abi.encode(5, "wojak", true)));

    vm.stopBroadcast();
  }
}

// run using
/**
forge script src/esp-contracts/examples/DxDAO/script/DxDSignalScript.s.sol:DxDSignalScript --rpc-url goerli --broadcast --private-key $GOERLI_PRIVATE_KEY
 */
