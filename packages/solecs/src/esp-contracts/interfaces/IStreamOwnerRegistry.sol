// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IStreamOwnerRegistry {

    function validOwner(uint256,address) external view returns(bool);

}