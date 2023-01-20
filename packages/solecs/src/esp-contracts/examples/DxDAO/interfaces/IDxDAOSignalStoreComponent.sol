// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { UserPoints } from "../lib/UserPoints.sol";

interface IDxDAOSignalStoreComponent {
  function getValue(uint256) external view returns (UserPoints memory);
}
