// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TimeLockedWallet {
    address public owner;
    uint256 public unlockTime;

    event Deposited(address indexed sender, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed receiver, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier isUnlocked() {
        require(block.timestamp >= unlockTime, "Funds are still locked");
        _;
    }

    constructor(uint256 _unlockTime) {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    function deposit() external payable onlyOwner {
        require(msg.value > 0, "Must send some ETH");
        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    function withdraw() external onlyOwner isUnlocked {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner).transfer(balance);
        emit Withdrawn(owner, balance);
    }

    function getTimeLeft() external view returns (uint256) {
        if (block.timestamp >= unlockTime) return 0;
        return unlockTime - block.timestamp;
    }
}
