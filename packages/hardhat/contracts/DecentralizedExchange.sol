// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DecentralizedExchange is Ownable, ReentrancyGuard {
    string public decentralizedExchangeName;
    mapping(address => mapping(address => uint256)) public tradingPairs;

    event TokensDeposited(address indexed user, address token, uint256 amount);
    event TokensWithdrawn(address indexed user, address token, uint256 amount);
    event Trade(address indexed user, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);

    constructor(string memory _dexName) {
        decentralizedExchangeName = _dexName;
    }

    function depositTokens(address _token, uint256 _amount) external {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        emit TokensDeposited(msg.sender, _token, _amount);
    }

    function withdrawTokens(address _token, uint256 _amount) external {
        require(tradingPairs[msg.sender][_token] >= _amount, "Insufficient balance");
        IERC20(_token).transfer(msg.sender, _amount);
        emit TokensWithdrawn(msg.sender, _token, _amount);
    }

    function createTrade(address _tokenIn, uint256 _amountIn, address _tokenOut, uint256 _amountOut) external nonReentrant {
        require(tradingPairs[msg.sender][_tokenIn] >= _amountIn, "Insufficient input token balance");
        tradingPairs[msg.sender][_tokenIn] -= _amountIn;
        tradingPairs[msg.sender][_tokenOut] += _amountOut;
        emit Trade(msg.sender, _tokenIn, _amountIn, _tokenOut, _amountOut);
    }
}