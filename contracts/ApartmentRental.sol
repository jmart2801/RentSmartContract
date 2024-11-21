// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ApartmentRental {
    // State variables
    address payable public owner;
    uint public apartmentsAvailable = 24; // Total apartments available for rent
    uint public ratePerMonth = 0.1 ether; // Rent in wei (0.1 Sepolia ETH)

    mapping(address => uint) public tenantLateFees; // Track late fees for tenants

    event RentPaid(address indexed tenant, uint amount);
    event RentUpdated(uint newRate);
    event LateFeeEnforced(address indexed tenant, uint lateFee);

    // Constructor
    constructor() {
        owner = payable(msg.sender);
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    modifier onlyTenant() {
        require(msg.sender != owner, "Only tenants");
        _;
    }

    // Pay rent function
    function payRent() external payable onlyTenant {
        require(apartmentsAvailable > 0, "No apartments available.");
        require(msg.value >= ratePerMonth, "Insufficient funds.");

        // Transfer rent to owner (using call instead of transfer for gas optimization)
        (bool success, ) = owner.call{value: msg.value}("");
        require(success, "Transfer failed");

        emit RentPaid(msg.sender, msg.value);
    }

    // Update rent function
    function updateRent(uint newRate) external onlyOwner {
        ratePerMonth = newRate;
        emit RentUpdated(newRate);
    }

    // Enforce late fee function
    function enforceLateFee(address tenant, uint lateFee) external onlyOwner {
        require(lateFee > 0, "Late fee must be greater than zero.");

        // Store the late fee for the tenant
        tenantLateFees[tenant] = lateFee;

        emit LateFeeEnforced(tenant, lateFee);
    }
}