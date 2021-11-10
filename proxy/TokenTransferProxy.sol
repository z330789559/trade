// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ProxyRegistry.sol";
import "../exchange/ERC20.sol";

contract TokenTransferProxy {

    /* Authentication registry. */
    ProxyRegistry public registry;

    /**
     * Call ERC20 `transferFrom`
     *
     * @dev Authenticated contract only
     * @param token ERC20 token address
     * @param from From address
     * @param to To address
     * @param amount Transfer amount
     */
    function transferFrom(address token, address from, address to, uint amount)
    public
    returns (bool)
    {
        require(registry.contracts(msg.sender));
        return ERC20(token).transferFrom(from, to, amount);
    }

}