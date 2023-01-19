// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { System } from '../../System.sol';

// ESP Core
import { IMemberRegistrySystem } from '../interfaces/IMemberRegistrySystem.sol';
import { DecodeBool } from '../logic/DecodeBool.sol';

/**
@notice contract abstract for deploying your own MemberRegistrySystem, which should implement logic to determine if a given address is valid for a system, and return a boolean answer
 */
abstract contract BaseMemberRegistrySystem is System, IMemberRegistrySystem {

    constructor(IWorld _world, address _components) System(_world, address(0)){}

    /**
    @param bytes return value should be a tightly packed boolean
     */
    function execute(bytes memory arguments) public returns(bytes memory) {
        (uint256 _stream, address _user) = abi.decode(arugments, (uint256,address));
        /**
        @notice Here goes any logic for determining if a user of an address is valid within a stream
        @notice This does not require the streamID, as this should already be checked before this system is called
        @notice May include external lookups to other contracts, ie. DAO token contracts
        @param isUserValid expected to be a tightly packed bool
         */
        bytes memory isUserValid = abi.encode(false);
        return isUserValid;
    }

    function executeTyped(uint256 stream, address user) public returns (bool) {
        return decodeBool(execute(abi.encode(stream, user)));
    }

}
