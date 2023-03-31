// SPDX-License-Identifier:MIT
pragma solidity ^0.8.9;

contract ContractA {
    function sendToAddress(address payable to) external payable {
        to.call{value: msg.value}("");
    }
}

contract ContractB {
    address payable public addConC;

    constructor(address payable _addConC) {
        addConC = _addConC;
    }

    receive() external payable {
        addConC.call{value: msg.value}("");
    }
}

contract ContractC {
    receive() external payable {}
}

contract ContractD {
    receive() external payable {
        revert("Reject by contract D");
    }
}
