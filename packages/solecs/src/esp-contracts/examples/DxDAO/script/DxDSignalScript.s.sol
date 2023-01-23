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
    uint256 deployerPrivateKey = vm.envUint("GOERLI_PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    DxDAOMemberRegistrySystem reg = DxDAOMemberRegistrySystem(0x9E058C762547455eEB80e1460f47dB503c60c997);

    bytes memory valid = reg.execute(abi.encode(1, tx.origin));

    console.log("Sender", tx.origin);
    console.log("Valid", decodeBool(valid));

    DxDAOMemberPointsRegistry memberpoints = DxDAOMemberPointsRegistry(0x104D7e73ba2CF955A813da67c37f5631aFc89619);

    uint256 points = memberpoints.getUserPoints(1, tx.origin);

    console.log("Points ", points);

    SignalRouterSystem router = SignalRouterSystem(0x44Fec79BaA6f6f9865bc61CB3566b56A57679A4e);

    router.execute(abi.encode(1, 0x1Ee7B1baAAC58b05c84EBE42aBFf6bDE5Aa504d9, abi.encode(60, "pepe", true)));

    vm.stopBroadcast();
  }

  // function testTemp() public {
  //     uint256 m = 5;
  //     assertEq(m,m);
  // }

  //   function testSignal() public {
  //     console.log("ORIGIN ", tx.origin);
  //     vm.prank(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
  //     console.log("ORIGIN ", msg.sender);
  //     // deposit 60 points into pepe
  //     router.execute(abi.encode(1, DxDmps, abi.encode(60, "pepe", true)));
  //     uint256 _val = DxDmapc.getValue(uint256(keccak256(abi.encode(1, abi.encode(tx.origin)))));
  //     assertEq(_val, 40, "Available points error");
  //     UserPoints memory _u = DxDssc.getValue(uint256(keccak256(abi.encode(1, abi.encode(tx.origin, "pepe")))));
  //     assertEq(_u.stream, 1, "Stream3 err");
  //     assertEq(_u.user, tx.origin, "Address err");
  //     assertEq(_u.signal, "pepe", "Signal err");
  //     assertEq(_u.pointsString, 60, "Points string err");
  //     assertEq(_u.totalPoints, 100, "Total points err");

  //     // withdraw 25 points from pepe and deposit 10 into wojak
  //     vm.prank(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
  //     router.execute(abi.encode(1, DxDmps, abi.encode(25, "pepe", false)));
  //     uint256 _val2 = DxDmapc.getValue(uint256(keccak256(abi.encode(1, abi.encode(tx.origin)))));
  //     assertEq(_val2, 65, "Available points error");
  //     _u = DxDssc.getValue(uint256(keccak256(abi.encode(1, abi.encode(tx.origin, "pepe")))));
  //     assertEq(_u.stream, 1, "Stream3 err");
  //     assertEq(_u.user, tx.origin, "Address err");
  //     assertEq(_u.signal, "pepe", "Signal err");
  //     assertEq(_u.pointsString, 35, "Points string err");
  //     assertEq(_u.totalPoints, 100, "Total points err");

  //     vm.prank(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
  //     router.execute(abi.encode(1, DxDmps, abi.encode(10, "wojak", true)));
  //     uint256 _val3 = DxDmapc.getValue(uint256(keccak256(abi.encode(1, abi.encode(tx.origin)))));
  //     assertEq(_val3, 55, "Available points error");
  //     _u = DxDssc.getValue(uint256(keccak256(abi.encode(1, abi.encode(tx.origin, "wojak")))));
  //     assertEq(_u.stream, 1, "Stream3 err");
  //     assertEq(_u.user, tx.origin, "Address err");
  //     assertEq(_u.signal, "wojak", "Signal err");
  //     assertEq(_u.pointsString, 10, "Points string err");
  //     assertEq(_u.totalPoints, 100, "Total points err");
  //   }
  function decodeBool(bytes memory _data) internal pure returns (bool b) {
    assembly {
      // Load the length of data (first 32 bytes)
      let len := mload(_data)
      // Load the data after 32 bytes, so add 0x20
      b := mload(add(_data, 0x20))
    }
  }
}
