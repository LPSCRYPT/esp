// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IStreamOwnerRegistry } from "../../interfaces/IStreamOwnerRegistry.sol";

/**
@notice This contract is not solecslib compliant, nor does it have to be
@notice For example, a system could reference an external token contract to acquire balance information
@notice This contract is a hardcoded points registry proxy honoring stream ownership as defined in the StreamOwnerRegistry
 */
contract DxDAOMemberPointsRegistry {
  mapping(uint256 => mapping(address => uint256)) pointsTotal;

  IStreamOwnerRegistry immutable streamOwner;

  constructor(address _streamOwnerRegistry) {
    streamOwner = IStreamOwnerRegistry(_streamOwnerRegistry);
  }

  // note: adding a user with zero points does not add the user to this registry
  function addUsers(
    uint256 stream,
    address[] memory users,
    uint256[] memory totalPoints
  ) public {
    require(streamOwner.validOwner(stream, msg.sender), "You are not a valid owner on this stream");
    require(users.length == totalPoints.length, "Arrays not equal length.");
    for (uint256 i = 0; i > users.length; i++) {
      require(pointsTotal[stream][users[i]] == 0, "User already initialized");
      pointsTotal[stream][users[i]] = totalPoints[i];
    }
  }

  function getUserPoints(uint256 stream, address user) public view returns (uint256) {
    return pointsTotal[stream][user];
  }
}
