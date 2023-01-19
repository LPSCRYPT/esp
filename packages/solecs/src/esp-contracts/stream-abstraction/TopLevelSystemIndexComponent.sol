// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// MUD Core
import { BareComponent } from '../../BareComponent.sol';

// ESP Core
import { DecodeBool } from '../logic/DecodeBool.sol';

contract TopLevelSystemIndexComponent is BareComponent, DecodeBool {

    constructor(address world, uint256 id) BareComponent(world, id) {}

    function getValue(uint256 entity) public view returns (bool) {
        bytes memory rawValue = getRawValue(entity);
        if (rawValue.length > 0) {
            return decodeBool(rawValue);
        } else {
            return false;
        }
    }

}