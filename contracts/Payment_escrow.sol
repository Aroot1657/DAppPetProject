// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract EscrowContract {
    address public owner;
    IERC20 public stablecoin; // USDC token contract

    enum EscrowStatus { None, Locked, Released, Refunded }

    struct Escrow {
        address buyer;
        address seller;
        uint256 amount;
        EscrowStatus status;
    }

    mapping(bytes32 => Escrow) public escrows;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not admin");
        _;
    }

    constructor(address _stablecoin) {
        owner = msg.sender;
        stablecoin = IERC20(_stablecoin);
    }

    function lockEscrow(string memory orderId, address seller, uint256 amount) external {
        bytes32 key = keccak256(abi.encodePacked(orderId));
        require(escrows[key].status == EscrowStatus.None, "Escrow already exists");
        require(amount > 0, "Invalid amount");

        // Transfer USDC from buyer to contract
        require(stablecoin.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");

        escrows[key] = Escrow({
            buyer: msg.sender,
            seller: seller,
            amount: amount,
            status: EscrowStatus.Locked
        });
    }

    function releaseEscrow(string memory orderId) external onlyOwner {
        bytes32 key = keccak256(abi.encodePacked(orderId));
        Escrow storage escrow = escrows[key];
        require(escrow.status == EscrowStatus.Locked, "Escrow not locked");

        escrow.status = EscrowStatus.Released;
        require(stablecoin.transfer(escrow.seller, escrow.amount), "USDC release failed");
    }

    function refundEscrow(string memory orderId) external onlyOwner {
        bytes32 key = keccak256(abi.encodePacked(orderId));
        Escrow storage escrow = escrows[key];
        require(escrow.status == EscrowStatus.Locked, "Escrow not locked");

        escrow.status = EscrowStatus.Refunded;
        require(stablecoin.transfer(escrow.buyer, escrow.amount), "USDC refund failed");
    }
}
