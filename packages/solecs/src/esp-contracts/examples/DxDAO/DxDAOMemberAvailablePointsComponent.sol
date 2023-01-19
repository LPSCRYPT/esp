// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { Component } from '../../../Component.sol';

uint256 constant ID = uint256(keccak256("ESP.component.DxDAOMemberAvailablePointsComponent"));

contract DxDAOMemberAvailablePointsComponent is Component {

    constructor(address _router, address _world) Component(world, ID) {
        // Registers component update permissions to only the SignalRouterSystem
        authorizeWriter(_router);
        unauthorizeWriter(msg.sender);
    }

    function set(uint256 entity, UserPoints calldata value) public {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity) public view returns (UserPoints memory) {
        return abi.decode(getRawValue(entity), (UserPoints));
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