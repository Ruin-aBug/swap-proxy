// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

abstract contract Adminable {
    modifier onlyAdmin() {
        require(_isAdmin(), "@5|E99");
        _;
    }

    event NewAdmin(address indexed previousAdmin, address indexed admin);
    event SetAdmin(address indexed newAdmin);

    address private _admin;
    address public newAdmin;

    constructor() {
        _admin = msg.sender;
    }

    function admin() public view returns (address) {
        return _admin;
    }

    function _isAdmin() public view returns (bool) {
        return msg.sender == _admin;
    }

    function isAdmin(address to) public view returns (bool) {
        return to == _admin;
    }

    function setAdmin(address newAdmin_) public onlyAdmin {
        newAdmin = newAdmin_;
        emit SetAdmin(newAdmin);
    }

    function acceptAdmin() public {
        require(msg.sender == newAdmin, "@5|E4");
        emit NewAdmin(_admin, newAdmin);
        _admin = newAdmin;
        newAdmin = address(0);
    }
}
