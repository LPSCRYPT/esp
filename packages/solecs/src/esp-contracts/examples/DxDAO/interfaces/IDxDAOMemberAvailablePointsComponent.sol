// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IDxDAOMemberAvailablePointsComponent {
  function getValue(uint256) external view returns (uint256);
}
