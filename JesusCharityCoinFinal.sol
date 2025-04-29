// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burnToDead(uint256 amount) external;
    function totalRareBurned() external view returns (uint256);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction overflow");
        return a - b;
    }
}

contract JesusCharityCoin is ERC20Interface {
    using SafeMath for uint256;

    string public name = "Jesus Charity Coin";
    string public symbol = "JCC";
    uint8 public decimals = 18;
    uint256 private _totalSupply;
    address public owner;
    uint256 private _rareBurned;
    bool public paused = false;

    mapping(address => uint256) private _balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event BurnToDead(address indexed from, uint256 amount);
    event Paused(bool status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        _totalSupply = initialSupply * (10 ** uint256(decimals));
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function pause(bool _state) external onlyOwner {
        paused = _state;
        emit Paused(_state);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override whenNotPaused returns (bool) {
        require(recipient != address(0), "Invalid recipient address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function burnToDead(uint256 amount) external override onlyOwner whenNotPaused {
        require(_balances[msg.sender] >= amount, "Insufficient balance to burn");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        _rareBurned = _rareBurned.add(amount);

        emit BurnToDead(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function totalRareBurned() external view override returns (uint256) {
        return _rareBurned;
    }
}
