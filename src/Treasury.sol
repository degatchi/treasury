pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

// --------------------------------------------------------------------------------------
//
// (c) Treasury 23/02/2022 | SPDX-License-Identifier: AGPL-3.0-only
//  Designed by, DeGatchi (https://github.com/DeGatchi).
//
// --------------------------------------------------------------------------------------

interface IWFTM {
    function withdraw(uint) external;
    function deposit() external payable;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Treasury is Ownable {
    event Authorised(address indexed addr);
    event Unauthorised(address indexed addr);
    event Erc20Recover(IERC20 indexed token, address indexed to, uint256 indexed amount);

    address constant wftm = 0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83;

    mapping(address => bool) public authorised;

    modifier onlyAuth() {
        require(authorised[msg.sender], "UNAUTHORISED");
        _;
    }

    constructor() {
        authorised[msg.sender] = true;
    }
    
    receive() external payable {
        // convert FTM to WFTM when received
        IWFTM(wftm).deposit{value: msg.value}();
    }

    function destroy() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }

    function authorise(address addr) external {
        require(!authorised[addr], "AUTHORISED");
        authorised[addr] = true;
        emit Authorised(addr);
    }

    function unauthorise(address addr) external {
        require(!authorised[addr], "UNAUTHORISED");
        authorised[addr] = false;
        emit Authorised(addr);
    }

    function erc20Recover(IERC20 token, address to, uint256 amount) external onlyAuth {
        token.transfer(to, amount);
        emit Erc20Recover(token, to, amount);
    }

    function erc20RecoverAll(IERC20 token, address to) external onlyAuth {
        uint256 amount = token.balanceOf(address(this));
        token.transfer(to, amount);
        emit Erc20Recover(token, to, amount);
    }
}
