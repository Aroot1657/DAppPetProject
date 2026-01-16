// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
I declare that this code was written by me.
I will not copy or allow others to copy my code.
I understand that copying code is considered as plagiarism.

Student Name: Arut
Student ID: 24027003
Class: C372-003
Date created: 16/01/2026
*/

contract EscrowView {

    // Matches OnlineStoreDisputes OrderStatus
    enum OrderStatus {
        None,
        Paid,
        Disputed,
        Resolved
    }

    struct OrderView {
        OrderStatus status;
        uint256 escrowAmount; // USDC amount locked in escrow
    }

    // orderId => order view info
    mapping(uint256 => OrderView) public orders;

    // ---------------------------------
    // VIEW (READ-ONLY) FUNCTIONS
    // ---------------------------------

    // Returns current order status
    function getOrderStatus(uint256 orderId)
        external
        view
        returns (OrderStatus)
    {
        return orders[orderId].status;
    }

    // Returns escrowed USDC amount for the order
    function getEscrowAmount(uint256 orderId)
        external
        view
        returns (uint256)
    {
        return orders[orderId].escrowAmount;
    }

    // ---------------------------------
    // OPTIONAL: helper for demo/testing
    // (would be removed in production)
    // ---------------------------------
    function _setOrder(
        uint256 orderId,
        OrderStatus status,
        uint256 amount
    ) external {
        orders[orderId] = OrderView(status, amount);
    }
}
