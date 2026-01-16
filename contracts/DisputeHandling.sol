/*
I declare that this code was written by me.
I will not copy or allow others to copy my code.
I understand that copying code is considered as plagiarism.

Student Name: Saw Kaung Khant Thiha
Student ID: 24025215
Class: C372-003
Date created: 16/01/2026
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract OnlineStoreDisputes {
    // USDC token contract
    IERC20 public usdc;

    // Who can resolve disputes
    address public arbitrator;

    constructor(address usdcAddress) {
        require(usdcAddress != address(0), "Invalid USDC address");
        usdc = IERC20(usdcAddress);
        arbitrator = msg.sender;
    }

    function changeArbitrator(address newArbitrator) public {
        require(msg.sender == arbitrator, "Only arbitrator can change arbitrator");
        require(newArbitrator != address(0), "Invalid arbitrator");
        arbitrator = newArbitrator;
    }

    enum OrderStatus {
        None,
        Paid,
        Disputed,
        Resolved
    }

    enum DisputeOutcome {
        None,
        RefundBuyer,
        ReleaseToSeller
    }

    struct Order {
        address buyer;
        address seller;
        uint256 amount;     // USDC amount (USDC has 6 decimals)
        OrderStatus status;
        bool payoutDone;
    }

    struct Dispute {
        bool exists;
        address openedBy;
        string reason;
        DisputeOutcome outcome;
    }

    mapping(uint256 => Order) public orders;
    mapping(uint256 => Dispute) public disputes;
    uint256 public nextOrderId;

    event OrderCreated(uint256 indexed orderId, address indexed buyer, address indexed seller, uint256 amount);
    event DisputeRaised(uint256 indexed orderId, address indexed openedBy, string reason);
    event DisputeResolved(uint256 indexed orderId, DisputeOutcome outcome);

    /*
      Buyer creates order AND locks USDC into escrow in one step.

      Important:
      - Buyer must call USDC.approve(thisContractAddress, amount) BEFORE calling this.
    */
    function createOrder(address seller, uint256 amount) public returns (uint256) {
        require(seller != address(0), "Invalid seller");
        require(amount > 0, "Amount must be > 0");

        // Pull USDC from buyer into this contract (escrow)
        bool ok = usdc.transferFrom(msg.sender, address(this), amount);
        require(ok, "USDC transferFrom failed");

        uint256 orderId = nextOrderId;
        nextOrderId = nextOrderId + 1;

        orders[orderId] = Order(
            msg.sender,
            seller,
            amount,
            OrderStatus.Paid,
            false
        );

        emit OrderCreated(orderId, msg.sender, seller, amount);
        return orderId;
    }

    // Buyer OR seller can open a dispute
    function raiseDispute(uint256 orderId, string memory reason) public {
        Order storage order = orders[orderId];

        require(order.status == OrderStatus.Paid, "Order not in a disputable state");
        require(msg.sender == order.buyer || msg.sender == order.seller, "Not buyer or seller");
        require(disputes[orderId].exists == false, "Dispute already exists");

        disputes[orderId] = Dispute(
            true,
            msg.sender,
            reason,
            DisputeOutcome.None
        );

        order.status = OrderStatus.Disputed;

        emit DisputeRaised(orderId, msg.sender, reason);
    }

    /*
      Arbitrator resolves dispute.

      outcome values:
      - DisputeOutcome.RefundBuyer (1)
      - DisputeOutcome.ReleaseToSeller (2)
    */
    function resolveDispute(uint256 orderId, DisputeOutcome outcome) public {
        require(msg.sender == arbitrator, "Only arbitrator can resolve");

        Order storage order = orders[orderId];
        Dispute storage dispute = disputes[orderId];

        require(order.status == OrderStatus.Disputed, "Order not disputed");
        require(dispute.exists == true, "No dispute found");
        require(order.payoutDone == false, "Payout already done");

        // Only allow 2 valid outcomes (no if/else needed)
        require(outcome == DisputeOutcome.RefundBuyer || outcome == DisputeOutcome.ReleaseToSeller, "Invalid outcome");

        dispute.outcome = outcome;
        order.status = OrderStatus.Resolved;
        order.payoutDone = true;

        // Payout using USDC transfer
        bool okBuyer = true;
        bool okSeller = true;

        if (outcome == DisputeOutcome.RefundBuyer) {
            okBuyer = usdc.transfer(order.buyer, order.amount);
            require(okBuyer, "USDC refund failed");
        }

        if (outcome == DisputeOutcome.ReleaseToSeller) {
            okSeller = usdc.transfer(order.seller, order.amount);
            require(okSeller, "USDC release failed");
        }

        emit DisputeResolved(orderId, outcome);
    }

    function canRaiseDispute(uint256 orderId, address user) public view returns (bool) {
        Order storage order = orders[orderId];

        bool isParty = (user == order.buyer) || (user == order.seller);
        bool isPaid = (order.status == OrderStatus.Paid);
        bool noDisputeYet = (disputes[orderId].exists == false);

        return isParty && isPaid && noDisputeYet;
    }
}
