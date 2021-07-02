// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6 <0.9.0;

import "./IERC20.sol";
import "./Ownable.sol";

interface IUniswapV2Router02 {
    function WETH() external view returns (address);

    function factory() external view returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable;

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Factory {
    function createPair(address token1, address token2)
        external
        returns (address);
}

/*
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%,.............,&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(...(@@@@@@@@@@@@@@@@@*...%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@...&@@@@@@@@@@@@@@@@@@@@@@@@@%..*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&..@@#....&@@@@@@&##%@@@@@@@&....&@#..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@............#@@@@@@@(,........../@&..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/./@@........%@@@@@@@@@@@@@@@@@@.......#@@,.%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*.%@@@.....(@@@@@@@@@@@@@@@@@@@@@@@@.....@@@/.#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&.*@@@@*../@@@@@@@@@@@@@@@@@@@@@@@@@@@%..&@@@@,.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@@..@@@@@.......*@@@@@.......*@@@@@..@@@@@..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@/.%@@@#....@@*.@@@@@@@.%@@....@@@@%.(@@@@..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@..@@@@........@@@@@@@@#........@@@@..@@@@..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,.@@@@..@@@@@,..,..@@@@...@@@@.....(@@@@@..@@@&./@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.,@@@@..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%.*@@.....,@@@@@@@@@@@@@@@@@@@@@@@@@#,...*@@,.&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%...............*%&@@@@@@@@&#,..............@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..........(@@@@@@@@@&&@@@@@@@@*..........@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@............,*@#######%*.............@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%............,(#%%#,............%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.,......../////........,,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&......))(((......@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&*%@@@@@@@%*&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@@%..@@*./@@@@@..@@&...@@@@%..@@@..,@@@*,@@@@..@@%..@@&..@@#..@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@..........@@*./@@@@@..@@&..(.,@@%..@&..@@@,....#@@.......@@@@,...#@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@@%..@@*./@@@@@..@@&..@@%..(..@@..@@@@@@,.#@@..@*..@@@@@@..%@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@@%..@@@...*(...@@@&..@@@@&...@@@...,(*..,@@@..@@@/..@@@@..%@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..**,...@@@(../@@@@@...@@@@@..@@@..*,....@@@@@@...@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@.,@@/.,,.*@@@@..(.,@@@..@@@..@@@@@..&@@@,.%..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..(((%@@@,.*&&,.,@@@..@@%..&..@@@..@@@@@..#@%..&&%..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..@@@@@@,./@@@@(.,@@..@@@@@...@@@..@@%,..&@#..@@@@@..@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 */

/**
1. Holders who are included into rewards also charged by constant fee. That fee is proportionally shared between holders
2. Rewards sent to holders immediatelly
3. Tokens are burn on each transaction until 60% are burn.
4. Liquidity pool on pancake must be locked using Unicrypt Locker
 */

contract HungryPanda is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => bool) private excludedFromFee;
    address[] public holdersRewarded;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint8 private constant _decimals = 18;
    uint256 private constant DECIMALFACTOR = 10**_decimals;
    uint256 private _totalSupply = 10**17 * DECIMALFACTOR; // 100 000 000 000 000 000

    string private _name = "HungryPanda";
    string private _symbol = "HGP";

    uint256 public constant maxTxAmount = 10**15 * DECIMALFACTOR; // 1% 1 000 000 000 000 000
    uint256 public constant minimalSupply = 4 * 10**16 * DECIMALFACTOR; // 60% can be burnt 40 000 000 000 000 000
    uint256 public constant numTokensSellToAddLiquidity =
        10 * 10**13 * DECIMALFACTOR; // 0.01% 10 000 000 000 000

    uint256 public taxFee = 4;
    uint256 public burnFee = 1;
    uint256 public liquidityFee = 4;
    uint256 public supportFee = 1;
    uint256 public taxFeeOrigin = taxFee;
    uint256 public burnFeeOrigin = burnFee;
    uint256 public liquidityFeeOrigin = liquidityFee;
    uint256 public supportFeeOrigin = supportFee;

    uint256 public totalBurned = 0;
    uint256 public rewardTotal = 0;
    uint256 public totalSupported = 0;
    address public immutable supportWallet;

    uint256 public constant feeGranularity = 100;
    uint256 public immutable bornAtTime;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable _WETH;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool private _paused = false;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event Paused(address account);
    event Unpaused(address account);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier whenNotPaused {
        require(!_paused, "ERC20: paused");
        _;
    }

    constructor(address _router, address _wallet) Ownable() {
        bornAtTime = block.timestamp;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        _WETH = _uniswapV2Router.WETH();
        uniswapV2Pair = _uniswapV2Pair;
        // transfer ownership to contract
        excludedFromFee[address(this)] = true;
        excludedFromFee[_msgSender()] = true;
        excludedFromFee[address(_uniswapV2Router)] = true;
        excludedFromFee[_uniswapV2Pair] = true;
        // must be added explicitly ...
        holdersRewarded.push(_msgSender());

        supportWallet = _wallet;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function burn(address _sender, uint256 _toBeBurned) private {
        uint256 newSupply = _totalSupply - _toBeBurned;
        if (newSupply < minimalSupply) {
            newSupply = minimalSupply;
        }
        uint256 reallyBurned = _totalSupply - newSupply;
        if (reallyBurned <= 0) {
            return;
        }
        _totalSupply = newSupply;
        totalBurned += reallyBurned;
        emit Transfer(_sender, address(0), reallyBurned);
    }

    function shareRewards(address _sender, uint256 _fee) private {
        rewardTotal += _fee;
        uint256 integer = _totalSupply / DECIMALFACTOR;
        for (uint256 index = 0; index < holdersRewarded.length; index++) {
            address holder = holdersRewarded[index];
            uint256 balance = _balances[holder] / DECIMALFACTOR;
            if (balance == 0) {
                continue;
            }
            uint256 reward = _fee / (integer / balance);
            _balances[holder] += reward;
            emit Transfer(_sender, holder, reward);
        }
    }

    function takeSupport(address _sender, uint256 _toBeTaken) private {
        _balances[supportWallet] += _toBeTaken;
        totalSupported += _toBeTaken;
        emit Transfer(_sender, supportWallet, _toBeTaken);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function excludeFromFee(address _address) public onlyOwner {
        require(!excludedFromFee[_address], "Panda: already excluded");
        uint256 len = holdersRewarded.length;
        for (uint256 index = 0; index < len; index++) {
            if (_address == holdersRewarded[index]) {
                holdersRewarded[index] = holdersRewarded[len - 1];
                holdersRewarded.pop();
            }
        }
        excludedFromFee[_address] = true;
    }

    function includeToFee(address _address) public onlyOwner {
        require(excludedFromFee[_address], "Panda: already included");
        excludedFromFee[_address] = false;
        holdersRewarded.push(_address);
    }

    function pause() public onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _account)
        public
        view
        override
        returns (uint256)
    {
        return _balances[_account];
    }

    function transfer(address _recipient, uint256 _amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), _spender, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public override returns (bool) {
        _transfer(_sender, _recipient, _amount);

        uint256 currentAllowance = _allowances[_sender][_msgSender()];
        require(
            currentAllowance >= _amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(_sender, _msgSender(), currentAllowance - _amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address _spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][_spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), _spender, currentAllowance - subtractedValue);

        return true;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function makePairPath() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        return path;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = makePairPath();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    // if _sender is a pair (excludedFromFee), then _recipient sells tokens, extra charge _recipient but not a sender
    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal whenNotPaused {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(
            _recipient != address(0),
            "ERC20: transfer to the zero address"
        );
        require(_amount > 0, "ERC20: amount must be greater than zero");
        uint256 senderBalance = _balances[_sender];
        require(
            senderBalance >= _amount,
            "ERC20: transfer amount exceeds balance"
        );
        if (_sender != owner() && _recipient != owner()) {
            require(
                _amount <= maxTxAmount,
                "ERC20: transfer amount exceeds maximum"
            );
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= maxTxAmount) {
            // should we ?
            contractTokenBalance = maxTxAmount;
        }
        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            _sender != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddLiquidity;
            swapAndLiquify(contractTokenBalance);
        }
        bool takeFee = true;
        if (excludedFromFee[_sender] && excludedFromFee[_recipient]) {
            takeFee = false;
        }
        if (!takeFee) disableFee();
        _transferWithFee(_sender, _recipient, _amount);
        if (!takeFee) enableFee();
    }

    function getValues(uint256 _amount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 amountToBurn = (_amount / feeGranularity) * burnFee;
        uint256 amountToSupport = (_amount / feeGranularity) * supportFee;
        uint256 amountToCharge = (_amount / feeGranularity) * taxFee;
        uint256 amountToAddLiquidity = (_amount / feeGranularity) *
            liquidityFee;
        uint256 amountToReceive = _amount -
            amountToBurn -
            amountToSupport -
            amountToCharge -
            amountToAddLiquidity;
        return (
            amountToBurn,
            amountToSupport,
            amountToCharge,
            amountToAddLiquidity,
            amountToReceive
        );
    }

    // _transferWithFee charges sender and recepient. Any tokens movement are charged to motivate holders hold tokens
    function _transferWithFee(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        (
            uint256 amountToBurn,
            uint256 amountToSupport,
            uint256 amountToCharge,
            uint256 amountToAddLiquidity,
            uint256 amountToReceive
        ) = getValues(_amount);
        // collect fees
        shareRewards(_sender, amountToCharge);
        burn(_sender, amountToBurn);
        takeSupport(_sender, amountToSupport);

        _balances[address(this)] += amountToAddLiquidity;
        _balances[_sender] -= _amount;
        _balances[_recipient] += amountToReceive;
        if (!excludedFromFee[_recipient]) {
            holdersRewarded.push(_recipient);
        }
        emit Transfer(_sender, _recipient, amountToReceive);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function disableFee() private {
        taxFeeOrigin = taxFee;
        burnFeeOrigin = burnFee;
        liquidityFeeOrigin = liquidityFee;
        supportFeeOrigin = supportFeeOrigin;
        taxFee = 0;
        burnFee = 0;
        liquidityFee = 0;
        supportFee = 0;
    }

    function enableFee() private {
        taxFee = taxFeeOrigin;
        burnFee = burnFeeOrigin;
        liquidityFee = liquidityFeeOrigin;
        supportFee = supportFeeOrigin;
    }

    function totalHolders() public view returns (uint256) {
        return holdersRewarded.length;
    }
}
