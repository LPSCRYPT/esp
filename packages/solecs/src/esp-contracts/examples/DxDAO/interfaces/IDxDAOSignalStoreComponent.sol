// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IDxDAOSignalStoreComponent {
    struct UserPoints {
        uint256 stream;
        address user;
        string signal;
        uint256 pointsString;
        uint256 totalPoints;
    }
    function getValue(uint256) external view returns(UserPoints memory);
}