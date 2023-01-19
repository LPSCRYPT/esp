// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IMemberRegistrySystem {
    function executeTyped(uint256,address) external returns(bool);
}