// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IPoolAddressesProvider, IPool, IFlashLoanSimpleReceiver } from "https://github.com/aave/core-v3/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import { IERC20 } from "https://github.com/aave/core-v3/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

interface IFlashLoanSimpleReceiver {
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

contract FlashLoanExample is IFlashLoanSimpleReceiver {
    IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
    IPool public immutable POOL;
    address public owner;

    constructor(address _addressProvider) {
        ADDRESSES_PROVIDER = IPoolAddressesProvider(_addressProvider);
        POOL = IPool(ADDRESSES_PROVIDER.getPool());
        owner = msg.sender;
    }

    // Call this function to request a flash loan
    function requestFlashLoan(address token, uint256 amount) external {
        require(msg.sender == owner, "Only owner can request");

        POOL.flashLoanSimple(
            address(this),
            token,
            amount,
            bytes(""), // extra params if needed
            0 // referral code
        );
    }

    // Aave will call this function after giving you the loan
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // ✅ Here you now have the borrowed 'amount' of 'asset'
        // You can do anything here! (Arbitrage, liquidation, etc.)

        // Example: just log that flash loan was successful
        // (Or you could add your logic like swapping tokens here)

        // IMPORTANT: Pay back the loan + premium
        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }
}
