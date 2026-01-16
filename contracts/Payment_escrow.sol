/*
I declare that this code was written by me.
I will not copy or allow others to copy my code.
I understand that copying code is considered as plagiarism.

Student Name: Tay Yu Cheng
Student ID: 24026492
Class: C372-003
Date created: 16/01/2026
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract EscrowPayment {
    address public owner;
    IERC20 public usdc;

    enum EscrowStatus { None, Locked, Released, Refunded }

    struct Escrow {
        address buyer;
        address seller;
        uint256 amount;
        EscrowStatus status;
    }

    // Mapping of orderId to Escrow struct stored in permanent blockchain storage
    mapping(string => Escrow) public escrows;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor(address usdcAddress) {
        require(usdcAddress != address(0), "Invalid USDC address");
        usdc = IERC20(usdcAddress);
        owner = msg.sender;
    }

    // Locks USDC from buyer into escrow
    function lockEscrow(string memory orderId, address seller, uint256 amount) external {
        require(seller != address(0), "Invalid seller address");
        require(amount > 0, "Amount must be greater than 0");

        Escrow storage escrow = escrows[orderId];
        require(escrow.status == EscrowStatus.None, "Escrow already exists");

        bool success = usdc.transferFrom(msg.sender, address(this), amount);
        require(success, "USDC transfer failed");

        escrows[orderId] = Escrow({
            buyer: msg.sender,
            seller: seller,
            amount: amount,
            status: EscrowStatus.Locked
        });
    }

    // Releases funds to seller after confirmation
    function releaseEscrow(string memory orderId) external onlyOwner {
        Escrow storage escrow = escrows[orderId];
        require(escrow.status == EscrowStatus.Locked, "Escrow not locked");

        escrow.status = EscrowStatus.Released;
        bool success = usdc.transfer(escrow.seller, escrow.amount);
        require(success, "USDC release failed");
    }

    // Refunds buyer if necessary
    function refundEscrow(string memory orderId) external onlyOwner {
        Escrow storage escrow = escrows[orderId];
        require(escrow.status == EscrowStatus.Locked, "Escrow not locked");

        escrow.status = EscrowStatus.Refunded;
        bool success = usdc.transfer(escrow.buyer, escrow.amount);
        require(success, "USDC refund failed");
    }

    // Read-only: returns full escrow info
    function getEscrow(string memory orderId) external view returns (address, address, uint256, EscrowStatus) {
        Escrow storage escrow = escrows[orderId];
        return (escrow.buyer, escrow.seller, escrow.amount, escrow.status);
    }
}
