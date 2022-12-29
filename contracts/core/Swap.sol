// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import {PriceApi} from "../feeds/PriceApi.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BenzSwap {
    PriceApi private _priceApi;

    // contract admin
    address private _deployer;
    

    // charges 0.2% fee on every successful swaps
    uint private swapFee = 20;



    // token contract address => chainlink aggregrator address
    // only in the token paired to USD format
    mapping(address => address) public pairs;

   address public NATIVE_PAIR;
    address public BENZ_PAIR;

    constructor(address priceApI) {
        _priceApi = PriceApi(priceApI);
        _deployer = msg.sender;

        
    }

    // gets the exchanges rates for pair of tokens
    // with accordance to amount of tokens
    function estimate(
        address token0,
        address token1,
        uint256 amount0 // in wei
    ) public view returns (uint256) {
        int256 rate = _priceApi.getExchangeRate(pairs[token0], pairs[token1]);
        return (amount0 * uint256(rate)) / (10 ** 8);
    }

    // returns the contract address
    function getContractAddress() public view returns (address) {
        return address(this);
    }


    // === Swapping === //

   

    // MATIC => ERC20 e.g USDT
    function _transferSwappedTokens0(
        address token1,
        uint256 amount1,
        address owner
    ) private returns (uint256) {
        IERC20 quoteToken = IERC20(token1);

        uint256 _fee = ((amount1 / 1000) * swapFee);

        // give user their destination token minus fee
        quoteToken.transfer(owner, (amount1 - _fee));

        // convert fee to Benz tokens
        return estimate(token1, BENZ_PAIR, _fee);
    }

    // ERC20 e.g USDT => MATIC
    function _transferSwappedTokens1(
        address token0,
        uint256 amount0,
        uint256 amount1,
        address owner
    ) public payable returns (uint256) {
        IERC20 baseToken = IERC20(token0);

        uint256 _fee = ((amount1 / 1000) * swapFee);

        baseToken.transferFrom(owner, address(this), amount0);

        // give user their destination token minus fee
        require(
            address(this).balance >= amount1,
            "Contract: Insufficient Balance"
        );
        payable(owner).transfer(amount1 - _fee);

        // convert fee to Benz tokens
        return estimate(NATIVE_PAIR, BENZ_PAIR, _fee);
    }

    // ERC20 => ERC20
    function _transferSwappedTokens2(
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1,
        address owner
    ) private returns (uint256) {
        IERC20 baseToken = IERC20(token0);
        IERC20 quoteToken = IERC20(token1);

        uint256 _fee = ((amount1 / 1000) * swapFee);

        // tranfers the base token from user to the
        // smart contract
        baseToken.transferFrom(owner, address(this), amount0);

        // give user their destination token minus fee
        quoteToken.transfer(owner, (amount1 - _fee));

        // convert fee to Benz tokens
        return estimate(token1, BENZ_PAIR, _fee);
    }

    function _inWei(uint256 amount) private pure returns (uint256) {
        return amount * 10 ** 18;
    }


    // === Modifiers === //

  

    modifier onlyDeployer() {
        require(msg.sender == _deployer, "Only Deployer");
        _;
    }
}
