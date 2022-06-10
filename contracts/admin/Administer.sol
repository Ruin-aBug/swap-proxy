// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./Adminable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Administer is Adminable {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _opList;
    EnumerableSet.AddressSet private _lpList;
    EnumerableSet.AddressSet private _tokenList;
    EnumerableSet.AddressSet private _swapList;
    EnumerableSet.AddressSet private _arbitragerList;

/////////////////////////////////////////////////////////////////////////////////
    function addToken(address addr) public onlyAdmin returns (bool) {
        require(addr != address(0), "@50|1");
        return EnumerableSet.add(_tokenList, addr);
    }

    function batchAddToken(address[] calldata addrs) public onlyAdmin returns (uint) {
        uint added;
        for (uint idx; idx < addrs.length; idx++) {
            addToken(addrs[idx]);
            added++;
        }
        return added;
    }

    function removeToken(address addr) public onlyAdmin returns (bool) {
        return EnumerableSet.remove(_tokenList, addr);
    }

    function getAllTokens() public view returns (bytes32[] memory) {
        return _tokenList._inner._values;
    }

    function validateToken(address addr) public view returns (bool) {
        return EnumerableSet.contains(_tokenList, addr);
    }
//////////////////////////////////////////////////////////////////////////////
    function addSwap(address addr) public onlyAdmin returns (bool) {
        return EnumerableSet.add(_swapList, addr);
    }

    function batchAddSwap(address[] calldata addrs) public onlyAdmin returns (uint) {
        uint added;
        for (uint idx; idx < addrs.length; idx++) {
            addSwap(addrs[idx]);
            added++;
        }
        return added;
    }    

    function removeSwap(address addr) public onlyAdmin returns (bool) {
        return EnumerableSet.remove(_swapList, addr);
    }

    function getAllSwaps() public view returns (bytes32[] memory) {
        return _swapList._inner._values;
    }

    
    function validateSwap(address addr) public view returns (bool) {
        return EnumerableSet.contains(_swapList, addr);
    }
//////////////////////////////////////////////////////////////////////////////
    function addOP(address addr) public onlyAdmin returns (bool) {
        return EnumerableSet.add(_opList, addr);
    }

    function batchAddOp(address[] calldata addrs) public onlyAdmin returns (uint) {
        uint added;
        for (uint idx; idx < addrs.length; idx++) {
            addOP(addrs[idx]);
            added++;
        }
        return added;
    }       

    function removeOP(address addr) public onlyAdmin returns (bool) {
        return EnumerableSet.remove(_opList, addr);
    }

    function getAllOPs() public view returns (bytes32[] memory) {
        return _opList._inner._values;
    }

    function validateOP(address addr) public view returns (bool) {
        return EnumerableSet.contains(_opList, addr);
    }
//////////////////////////////////////////////////////////////////////////
    function addLP(address addr) public onlyAdmin returns(bool) {
        return EnumerableSet.add(_lpList, addr);
    }

    function batchAddLp(address[] calldata addrs) public onlyAdmin returns (uint) {
        uint added;
        for (uint idx; idx < addrs.length; idx++) {
            addLP(addrs[idx]);
            added++;
        }
        return added;
    }

    function removeLP(address addr) public onlyAdmin returns (bool) {
        return EnumerableSet.remove(_lpList, addr);
    }

    function getAllLPs() public view returns (bytes32[] memory) {
        return _lpList._inner._values;
    }

    function validateLP(address addr) public view returns (bool) {
        return EnumerableSet.contains(_lpList, addr);
    }

//////////////////////////////////////////////////////////////////////////////////////////
    // _arbitragerList
        function addArbitrager(address addr) public onlyAdmin returns(bool) {
        return EnumerableSet.add(_arbitragerList, addr);
    }

    function batchAddArbitrager(address[] calldata addrs) public onlyAdmin returns (uint) {
        uint added;
        for (uint idx; idx < addrs.length; idx++) {
            addArbitrager(addrs[idx]);
            added++;
        }
        return added;
    }

    function removeArbitrager(address addr) public onlyAdmin returns (bool) {
        return EnumerableSet.remove(_arbitragerList, addr);
    }

    function getAllArbitragers() public view returns (bytes32[] memory) {
        return _arbitragerList._inner._values;
    }

    function validateArbitrager(address addr) public view returns (bool) {
        return EnumerableSet.contains(_arbitragerList, addr);
    }
}
