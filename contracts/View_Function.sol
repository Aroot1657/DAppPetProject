// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
/*
I declare that this code was written by me.
I will not copy or allow others to copy my code.
I understand that copying code is considered as plagiarism.

Student Name:Arut
Student ID:24027003
Class:
Date created:
*/
contract EscrowView {

    enum OrderStatus { Locked, Shipped, Delivered, Disputed }

    struct Order {
        OrderStatus status;
        uint256 escrowBalance; // USDC held for the order
    }

    mapping(uint256 => Order) public orders;

    // -------------------------------
    // VIEW FUNCTIONS (READ-ONLY)
    // -------------------------------

    // View current order status
    function getOrderStatus(uint256 orderId)
        public
        view
        returns (OrderStatus)
    {
        return orders[orderId].status;
    }

    // View escrow balance for an order
    function getEscrowBalance(uint256 orderId)
        public
        view
        returns (uint256)
    {
        return orders[orderId].escrowBalance;
    }
}
