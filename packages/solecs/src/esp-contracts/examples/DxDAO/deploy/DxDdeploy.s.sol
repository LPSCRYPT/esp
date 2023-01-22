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

contract DxDdeploy is Script {
  // Vm internal immutable vm = Vm(HEVM_ADDRESS);

  World internal world;
  address internal worldAddress;
  SignalRouterSystem internal router;
  address internal routerAddress;
  StreamOwnerRegistry internal sor;
  address internal sorAddress;
  DxDAOMemberPointsRegistry internal DxDmpr;
  address internal DxDmprAddress;
  DxDAOMemberRegistrySystem internal DxDmrs;
  address internal DxDmrsAddress;
  DxDAOMemberAvailablePointsComponent internal DxDmapc;
  address internal DxDmapcAddress;
  DxDAOSignalStoreComponent internal DxDssc;
  address internal DxDsscAddress;
  DxDAOMemberPointsSystem internal DxDmps;
  address internal DxDmpsAddress;

  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    world = new World();
    world.init();
    worldAddress = address(world);

    router = new SignalRouterSystem(world);
    routerAddress = address(router);

    sor = router.RouterSOR();
    sorAddress = address(sor);
    address[] memory _empty;
    sor.streamRegister(1, _empty);

    DxDmpr = new DxDAOMemberPointsRegistry(sorAddress);
    DxDmprAddress = address(DxDmpr);

    DxDmrs = new DxDAOMemberRegistrySystem(DxDmprAddress, world);
    DxDmrsAddress = address(DxDmrs);

    sor.mutateMemberRegistrySystem(1, DxDmrsAddress);

    DxDmapc = new DxDAOMemberAvailablePointsComponent(routerAddress, worldAddress);
    DxDmapcAddress = address(DxDmapc);
    DxDssc = new DxDAOSignalStoreComponent(routerAddress, worldAddress);
    DxDsscAddress = address(DxDssc);

    DxDmps = new DxDAOMemberPointsSystem(routerAddress, DxDmprAddress, DxDsscAddress, DxDmapcAddress, world);
    DxDmpsAddress = address(DxDmps);

    sor.addOrRemoveTopLevelSystem(1, DxDmpsAddress, true);
    sor.addOrRemoveStreamSystem(1, DxDmpsAddress, true);

    // uint256[] memory _p = new uint256[](1);
    // _p[0] = 100;
    // address[] memory _a = new address[](1);
    // _a[0] = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    // DxDmpr.addUsers(1, _a, _p);
    // UserPoints memory _t = DxDssc.getValue(uint256(keccak256(abi.encode(1, abi.encode(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38, "pepe")))));
    // console.log("TEST! ",_t.stream);
    console.log("worldAddress ", worldAddress);
    console.log("routerAddress ", routerAddress);
    console.log("sorAddress ", sorAddress);
    console.log("DxDmprAddress ", DxDmprAddress);
    console.log("DxDmrsAddress ", DxDmrsAddress);
    console.log("DxDmapcAddress ", DxDmapcAddress);
    console.log("DxDsscAddress ", DxDsscAddress);
    console.log("DxDmpsAddress ", DxDmpsAddress);

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
}
