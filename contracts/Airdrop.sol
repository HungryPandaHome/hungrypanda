// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Airdrop {
    using SafeERC20 for IERC20;

    address public admin;
    mapping(address => bool) public processedAirdrops;
    IERC20 public token;
    uint256 public currentAirdropAmount = 0;
    uint256 public maxAirdropAmount = 0;
    uint256 public immutable START_DATE;

    event AirdropProcessed(address recipient, uint256 amount, uint256 date);

    constructor(address _admin, uint256 _openAfter) {
        admin = _admin;
        START_DATE = block.timestamp + _openAfter;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Airdrop: only admin");
        _;
    }

    modifier whenOpen() {
        require(block.timestamp >= START_DATE, "Airdrop: not started");
        _;
    }

    function updateAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }

    function setToken(address _token, uint256 _maxAmount) public onlyAdmin {
        token = IERC20(_token);
        maxAirdropAmount = _maxAmount;
    }

    function _claimTokens(
        address recipient,
        uint256 amount,
        bytes calldata signature
    ) internal {
        bytes32 message = prefixed(
            keccak256(abi.encodePacked(recipient, amount))
        );
        require(recoverSigner(message, signature) == admin, "wrong signature");
        require(
            processedAirdrops[recipient] == false,
            "airdrop already processed"
        );
        require(
            currentAirdropAmount + amount <= maxAirdropAmount,
            "airdropped 100% of the tokens"
        );
        processedAirdrops[recipient] = true;
        currentAirdropAmount += amount;
        token.safeTransfer(recipient, amount);
        emit AirdropProcessed(recipient, amount, block.timestamp);
    }

    function claimTokens(uint256 amount, bytes calldata signature)
        public
        whenOpen
    {
        _claimTokens(msg.sender, amount, signature);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        // Golang compatibility
        if (v == 0 || v == 1) {
            v += 27;
        }
        return (v, r, s);
    }
}
