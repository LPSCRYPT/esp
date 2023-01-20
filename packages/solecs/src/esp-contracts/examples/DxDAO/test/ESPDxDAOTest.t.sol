// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { DSTestPlus } from "solmate/test/utils/DSTestPlus.sol";
import { Vm } from "forge-std/Vm.sol";
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

contract ESPDxDAOTest is DSTestPlus {
  Vm internal immutable vm = Vm(HEVM_ADDRESS);

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

  function setUp() public {
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

    uint256[] memory _p = new uint256[](1);
    _p[0] = 100;
    address[] memory _a = new address[](1);
    _a[0] = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    DxDmpr.addUsers(1, _a, _p);
    // UserPoints memory _t = DxDssc.getValue(uint256(keccak256(abi.encode(1, abi.encode(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38, "pepe")))));
    // console.log("TEST! ",_t.stream);
  }

  // function testTemp() public {
  //     uint256 m = 5;
  //     assertEq(m,m);
  // }

  function testSignal() public {
    console.log("ORIGIN ", tx.origin);
    vm.prank(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
    console.log("ORIGIN ", msg.sender);
    router.execute(abi.encode(1, DxDmps, abi.encode(60, "pepe", true)));
    uint256 _val = DxDmapc.getValue(uint256(keccak256(abi.encode(1, abi.encode(tx.origin)))));
    assertEq(_val, 40, "Available points error");
    UserPoints memory _u = DxDssc.getValue(uint256(keccak256(abi.encode(1, abi.encode(tx.origin, "pepe")))));
    assertEq(_u.stream, 1, "Stream3 err");
    assertEq(_u.user, tx.origin, "Address err");
    assertEq(_u.signal, "pepe", "Signal err");
    assertEq(_u.pointsString, 60, "Points string err");
    assertEq(_u.totalPoints, 100, "Total points err");
  }
}
