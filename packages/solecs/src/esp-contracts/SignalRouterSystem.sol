// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD core
import { ISystem } from "../interfaces/ISystem.sol";
import { IWorld } from "../interfaces/IWorld.sol";

import { IComponent } from "../interfaces/IComponent.sol";
import { System } from "../System.sol";

// ESP core
import { ISignalRouterSystem } from "./interfaces/ISignalRouterSystem.sol";
import { IMemberRegistrySystem } from "./interfaces/IMemberRegistrySystem.sol";

import { StreamOwnerRegistry } from "./stream-abstraction/StreamOwnerRegistry.sol";
import { StreamMemberIndexComponent } from "./stream-abstraction/StreamMemberIndexComponent.sol";
import { TopLevelSystemIndexComponent } from "./stream-abstraction/TopLevelSystemIndexComponent.sol";
import { StreamSystemIndexComponent } from "./stream-abstraction/StreamSystemIndexComponent.sol";

contract SignalRouterSystem is System, ISignalRouterSystem {
  // set these upon Router deployment
  StreamOwnerRegistry public RouterSOR;
  StreamMemberIndexComponent public RouterSMIC;
  TopLevelSystemIndexComponent public RouterTLSIC;
  StreamSystemIndexComponent public RouterSSIC;

  address public immutable _this;

  address public immutable _worldAddress;

  /**@notice _streamCall preserves the integrity of the _stream ID for systems requesting state updates via reentrancy within a single call chain */
  uint256 public _streamCall;

  uint256 constant _SMIC_ID = uint256(keccak256("ESP.component.StreamMemberIndexComponent"));
  uint256 constant _TLSIC_ID = uint256(keccak256("ESP.component.TopLevelSystemIndexComponent"));
  uint256 constant _SSIC_ID = uint256(keccak256("ESP.component.StreamSystemIndexComponent"));

  constructor(IWorld _world) System(_world, address(0)) {
    _this = address(this);
    _worldAddress = address(_world);
    // Deploys necessary registry & indeces linked to this router
    RouterSMIC = new StreamMemberIndexComponent(_worldAddress, _SMIC_ID);
    RouterTLSIC = new TopLevelSystemIndexComponent(_worldAddress, _TLSIC_ID);
    RouterSSIC = new StreamSystemIndexComponent(_worldAddress, _SSIC_ID);
    RouterSOR = new StreamOwnerRegistry(_this, address(RouterSMIC), address(RouterTLSIC), address(RouterSSIC));
    // Update stream abstraction component owners to the stream registry
    RouterSMIC.authorizeWriter(address(RouterSOR));
    RouterTLSIC.authorizeWriter(address(RouterSOR));
    RouterSSIC.authorizeWriter(address(RouterSOR));
    RouterSSIC.unauthorizeWriter(_this);
    RouterTLSIC.unauthorizeWriter(_this);
    RouterSMIC.unauthorizeWriter(_this);
  }

  /**
    @param arguments formatted as (uint256 _stream, address _system, bytes _arguments)
    @param _stream is the unique streamID
    @param _system is the address of the system to execute in this call
    @param _arguments are arguments to be passed along to the system call
    @param _component is the address of the component to update, sent by a system requesting a state mutation
     */

  /**
     @dev possibly replace 'hard contract calls' to stream abstraction contract with interface calls to save on gas
      */

  function execute(bytes memory arguments) public override returns (bytes memory) {
    /**
        @notice _reentrancyCheck helps to determine if a user is the initial caller. This prevents malicious systems calling the router directly to mutate the state for a previously logged _streamCall. Should ensure that all execute calls must initiate from an end user calling this router - not from a user calling a system directly
        */

    if (tx.origin == msg.sender) {
      // executes if the caller is an account
      // currently prevents external contract entities / abstractions from calling this contract
      (uint256 _stream, address _system, bytes memory _arguments) = abi.decode(arguments, (uint256, address, bytes));

      // Checks is user is valid for stream
      address MemberRegistrySystemAddress = RouterSMIC.getValue(_stream);
      require(MemberRegistrySystemAddress != address(0), "No MemberRegistrySystem found at address");
      require(IMemberRegistrySystem(MemberRegistrySystemAddress).executeTyped(_stream, msg.sender), "Not valid member");

      // Checks if system to call is valid for stream
      require(
        RouterTLSIC.getValue(uint256(keccak256(abi.encode(_stream, _system)))),
        "System not valid at top level for stream"
      );

      // Reentrancy check
      _streamCall = _stream;

      // Calls valid StreamSystem
      ISystem(_system).execute(_arguments);
    } else {
      // executes if the caller is another contract

      (address _component, bytes memory keys, bytes memory value) = abi.decode(arguments, (address, bytes, bytes));

      // Checks if calling system is registered for state updates for this stream
      require(RouterSSIC.getValue(uint256(keccak256(abi.encode(_streamCall, msg.sender)))));

      // Unique key to update will always be a hash of the lookup keys and the streamID, which is stored in _streamCall upon initial Router call
      // State management using hashed key values is not ideal, and should be upgraded pending fixed implementation in MUD framework being dealt with here: https://github.com/latticexyz/mud/issues/347
      IComponent(_component).set(uint256(keccak256(abi.encode(_streamCall, keys))), value);
    }
  }

  /**
    @dev allows access to current _streamCall in downstream systems
     */
  function viewStreamCall() public view returns (uint256) {
    return _streamCall;
  }

  /**
  @dev Prevents malicious systems directly calling router to update another stream's state
  @dev You systems MUST implement this function after their last state update, or risk malicious state mutations!
  @dev For this reason, stream ID 0 is always unsafe and should never be used
  @dev Add check to make sure that streamID 0 can never be logged or called
   */
  function endCall() public {
    require(RouterSSIC.getValue(uint256(keccak256(abi.encode(_streamCall, msg.sender)))));
    delete _streamCall;
  }

  // /** Expects packed encoding */
  // function decodeAddress(bytes memory _data) private pure returns(address addr) {
  //     assembly {
  //     addr := mload(add(_data,20))
  //     }
  // }

  /** Expects packed encoding */
  // function decodeBool(bytes memory _data) private pure returns (bool b){
  //     assembly {
  //         // Load the length of data (first 32 bytes)
  //         let len := mload(_data)
  //         // Load the data after 32 bytes, so add 0x20
  //         b := mload(add(_data, 0x20))
  //     }
  // }
}
