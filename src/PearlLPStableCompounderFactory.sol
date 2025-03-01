// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "forge-std/console.sol";

import {PearlLPStableCompounder} from "./PearlLPStableCompounder.sol";

interface IStrategy {
    function setPerformanceFeeRecipient(address) external;

    function setKeeper(address) external;

    function setPendingManagement(address) external;
}

contract PearlLPStableCompounderFactory {
    event NewPearlLPStableCompounder(
        address indexed strategy,
        address indexed asset
    );

    address public management;
    address public performanceFeeRecipient;
    address public keeper;

    constructor(
        address _management,
        address _peformanceFeeRecipient,
        address _keeper
    ) {
        management = _management;
        performanceFeeRecipient = _peformanceFeeRecipient;
        keeper = _keeper;
    }

    /**
     * @notice Deploy a new Pearl Stable LP Compounder Strategy.
     * @dev This will set the msg.sender to all of the permisioned roles.
     * @param _asset The underlying asset for the lender to use.
     * @param _name The name for the lender to use.
     * @return . The address of the new lender.
     */
    function newPearlLPStableCompounder(
        address _asset,
        string memory _name
    ) external returns (address) {
        // We need to use the custom interface with the
        // tokenized strategies available setters.
        console.log("asset creation strategy: %s", _asset);
        IStrategy newStrategy = IStrategy(
            address(new PearlLPStableCompounder(_asset, _name))
        );

        newStrategy.setPerformanceFeeRecipient(performanceFeeRecipient);

        newStrategy.setKeeper(keeper);

        newStrategy.setPendingManagement(management);

        emit NewPearlLPStableCompounder(address(newStrategy), _asset);
        return address(newStrategy);
    }

    function setAddresses(
        address _management,
        address _perfomanceFeeRecipient,
        address _keeper
    ) external {
        require(msg.sender == management, "!management");
        management = _management;
        performanceFeeRecipient = _perfomanceFeeRecipient;
        keeper = _keeper;
    }
}
