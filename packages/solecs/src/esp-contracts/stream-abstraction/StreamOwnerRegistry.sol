// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { IComponent } from "../../interfaces/IComponent.sol";

// ESP Core
import { IStreamOwnerRegistry } from "../interfaces/IStreamOwnerRegistry.sol";

/**
@notice StreamOwnerRegistry maintains mappings of valid owners for particular streams in the context of a SignalRouterSystem
@notice Only owners registered here for particular streams can mutate StreamMemberIndexComponent, TopLevelSystemIndexComponent, and StreamSystemIndexComponent values
@notice Lazily built this not in soleclib systems/component compliance: to be upgraded to a system/component architecture at a later date
@dev StreamMemberIndexComponent, TopLevelSystemIndexComponent, and StreamSystemIndexComponent registered to this registry have their owners set to this contract. Therefore, all mutating calls to them must be routed through this registry.
 */

contract StreamOwnerRegistry is IStreamOwnerRegistry {
  mapping(uint256 => mapping(address => bool)) users;
  mapping(uint256 => bool) registeredStreams;

  address immutable router;
  address immutable SMIC;
  address immutable TLSIC;
  address immutable SSIC;

  constructor(
    address _router,
    address _SMIC,
    address _TLSIC,
    address _SSIC
  ) {
    router = _router;
    SMIC = _SMIC;
    TLSIC = _TLSIC;
    SSIC = _SSIC;
  }

  function streamRegister(uint256 _stream, address[] memory _users) public {
    if (registeredStreams[_stream]) {
      require(users[_stream][msg.sender], "Caller not valid on this stream");
      if (_users.length > 0) {
        for (uint256 i = 0; i < _users.length; i++) {
          users[_stream][_users[i]] = true;
        }
      }
    } else {
      registeredStreams[_stream] = true;
      users[_stream][msg.sender] = true;
      if (_users.length > 0) {
        for (uint256 i = 0; i > _users.length; i++) {
          users[_stream][_users[i]] = true;
        }
      }
    }
  }

  function validOwner(uint256 _stream, address _user) public view returns (bool) {
    return users[_stream][_user];
  }

  modifier onlyStreamOwner(uint256 _stream) {
    require(validOwner(_stream, msg.sender));
    _;
  }

  function mutateMemberRegistrySystem(uint256 _stream, address _system) public onlyStreamOwner(_stream) {
    IComponent(SMIC).set(_stream, abi.encode(_system));
  }

  /**
    @notice A stream may have one or more TopLevelSystems available to call
    @notice For a TopLevelSystem to mutate state, it must also be registered as a StreamSystem
    @param _add boolean for adding (true) or removing (false) a top level system from a stream
     */
  function addOrRemoveTopLevelSystem(
    uint256 _stream,
    address _system,
    bool _add
  ) public onlyStreamOwner(_stream) {
    bytes memory boolUpdate = abi.encodePacked(_add);
    IComponent(TLSIC).set(uint256(keccak256(abi.encode(_stream, _system))), boolUpdate);
  }

  /**
    @notice A stream may have one or more StreamSystems available permissioned for component state updates
    @param _add boolean for adding (true) or removing (false) a top level system from a stream
     */
  function addOrRemoveStreamSystem(
    uint256 _stream,
    address _system,
    bool _add
  ) public onlyStreamOwner(_stream) {
    bytes memory boolUpdate = abi.encodePacked(_add);
    IComponent(SSIC).set(uint256(keccak256(abi.encode(_stream, _system))), boolUpdate);
  }
}
