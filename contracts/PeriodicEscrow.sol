// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6 <0.9.0;

// should be able to withdraw amount of tokens once per month
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PeriodicEscrow {
    using SafeERC20 for IERC20;

    address public immutable recipient;
    uint256 public immutable INIT_DATE = block.timestamp;
    uint256 public immutable OPEN_DATE;
    uint256 public immutable TIME_PERIOD;

    uint256 public amount;
    uint256 public partAmount;
    uint256 public parts = 0;
    uint256 public partsAreTaken = 0;
    uint256 public totalWithdrawn = 0;

    address public admin;

    IERC20 public token;
    bool isEntered = false;

    constructor(
        address _recepient,
        uint256 _openAfter,
        uint256 _periodSize
    ) {
        admin = msg.sender;
        recipient = _recepient;
        TIME_PERIOD = _periodSize;
        OPEN_DATE = block.timestamp + _openAfter;
    }

    modifier whenOpened() {
        require(block.timestamp >= OPEN_DATE, "Escrow: is not opened yet");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Escrow: only admin");
        _;
    }

    modifier onlyRecipient() {
        require(msg.sender == recipient, "Escrow: only recipient");
        _;
    }

    modifier notTaken() {
        require(partsAreTaken < parts, "Escrow: all parts were taken");
        _;
    }

    modifier whenNotLocked() {
        require(!isEntered, "Escrow: alredy entered");
        isEntered = true;
        _;
        isEntered = false;
    }

    // sets target token ...
    function setToken(
        address _token,
        uint256 _amount,
        uint256 _parts
    ) public onlyAdmin {
        token = IERC20(_token);
        amount = _amount;
        parts = _parts;
        partAmount = _amount / _parts;
    }

    // deliver ...
    function deliver() public onlyAdmin returns (bool) {
        // transfer tokens to recepient if allowed ...
        _transfer();
        return true;
    }

    // recepient can withdraw tokens by himself ...
    function withdraw() public onlyRecipient returns (bool) {
        _transfer();
        return true;
    }

    function _periodsPast() private view returns (uint256) {
        return (block.timestamp - OPEN_DATE) / TIME_PERIOD;
    }

    // _transfer transfers allowed amount of tokens to recipient ...
    // parts taken must be less then total parts
    // and periods must be greater then  partsAreTaken ...
    function _transfer() private whenOpened whenNotLocked notTaken {
        uint256 periods = _periodsPast();
        require(periods > partsAreTaken, "Escrow: to early");
        token.safeTransfer(recipient, partAmount);
        totalWithdrawn += partAmount;
        partsAreTaken += 1;
    }
}
