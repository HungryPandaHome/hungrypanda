// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6 <0.9.0;

import "./interfaces/IERC20.sol";
import "./security/Ownable.sol";

import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";

import "./interfaces/IMigrateToken.sol";

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

contract HungryPanda is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 public totalReward;
    mapping(address => bool) private excludedFromFee;

    uint8 private constant _decimals = 18;
    uint256 private constant DECIMALFACTOR = 10**_decimals;
    uint256 private _totalSupply = 10**17 * DECIMALFACTOR;

    string private _name = "HungryPanda";
    string private _symbol = "HGP";

    uint256 public constant minimalSupply = 4 * 10**16 * DECIMALFACTOR; // 60% can be burnt 40 000 000 000 000 000
    uint16 public constant percentageGranularity = 10000;
    uint8 public maxTxAmountPercentage = 100; // 1%
    uint8 public numTokensSellToAddLiquidityPercentage = 1; // 0,01%

    uint256 public taxFee = 200; // 2%
    uint256 public liquidityFee = 500; // 5%
    uint256 public supportFee = 200; // 2%

    uint256 public taxFeeOrigin = taxFee;
    uint256 public liquidityFeeOrigin = liquidityFee;
    uint256 public supportFeeOrigin = supportFee;

    uint256 public rewardTotal = 0;
    uint256 public totalSupported = 0;
    uint256 public totalBurned = 0;

    address public immutable supportWallet;

    uint256 public immutable bornAtTime;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable _WETH;

    bool locker = false;
    bool migrationLocker = false;
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

    modifier lockMutex {
        locker = true;
        _;
        locker = false;
    }

    modifier lockMigrationMutex {
        migrationLocker = true;
        _;
        migrationLocker = false;
    }

    modifier whenNotPaused {
        require(!_paused, "ERC20: paused");
        _;
    }

    IMigrateToken _oldToken;
    uint256 private lastMigratedIndex;

    constructor(
        address _router,
        address _wallet,
        address _token
    ) Ownable() {
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

        supportWallet = _wallet;

        // set values from old token
        _oldToken = IMigrateToken(_token);
        _totalSupply = _oldToken.totalSupply();

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // Protected migration function ...
    function migrateOldToken(uint256 _size) public onlyOwner returns (bool) {
        require(!migrationLocker, "Migrate:  mutex is locked");
        return _migrateOldToken(_size);
    }

    function _migrateOldToken(uint256 _size)
        private
        lockMigrationMutex
        returns (bool)
    {
        uint256 highIndex = lastMigratedIndex + _size;
        uint256 total = _oldToken.totalHolders();
        if (highIndex > total) {
            highIndex = total;
        }
        for (uint256 index = lastMigratedIndex; index < highIndex; index++) {
            address holder = _oldToken.holdersRewarded(index);
            uint256 balance = _oldToken.balanceOf(holder);
            _balances[holder] = balance;
            _balances[_msgSender()] -= balance;
        }
        bool transactionFinished = lastMigratedIndex + _size > total;
        // update last migration index
        lastMigratedIndex = highIndex;

        return transactionFinished;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

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
        (uint256 constBalance, uint256 rewardBalance) = _getBalances(_account);
        return (constBalance + rewardBalance);
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

    // Public interface ...
    function setMaxTxAmountPercent(uint8 _percentage) public onlyOwner {
        require(
            _percentage <= percentageGranularity,
            "Panda: percentage value to high"
        );
        maxTxAmountPercentage = _percentage;
    }

    function setNumTokensSellToAddLiquidity(uint8 _percentage)
        public
        onlyOwner
    {
        require(
            _percentage <= percentageGranularity,
            "Panda: percentage value to high"
        );
        numTokensSellToAddLiquidityPercentage = _percentage;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function excludeFromFee(address _address) public onlyOwner {
        require(!excludedFromFee[_address], "Panda: already excluded");
        excludedFromFee[_address] = true;
    }

    function includeToFee(address _address) public onlyOwner {
        require(excludedFromFee[_address], "Panda: already included");
        excludedFromFee[_address] = false;
    }

    function pause() public onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    // Private interface ...
    function _swapAndLiquify(uint256 contractTokenBalance) private lockMutex {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        _swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _makePairPath() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        return path;
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = _makePairPath();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
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

    function _getBalances(address _holder)
        private
        view
        returns (uint256, uint256)
    {
        uint256 balance = _balances[_holder];
        if (balance == 0) {
            return (0, 0);
        }
        uint256 rate = _totalSupply / balance;
        if (rate == 0) {
            return (balance, 0);
        }
        return (balance, totalReward / rate);
    }

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
        uint256 maxTxAmount = _maxTxAmount();
        if (_sender != owner() && _recipient != owner()) {
            require(
                _amount <= maxTxAmount,
                "ERC20: transfer amount exceeds maximum"
            );
        }
        require(
            balanceOf(_sender) >= _amount,
            "ERC20: transfer amount exceeds balance"
        );
        // substruct sender balance and total owned rewards
        _reflectSender(_sender, _amount);

        // add liquidity logic ...
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= maxTxAmount) {
            // should we ?
            contractTokenBalance = maxTxAmount;
        }

        uint256 numTokensSellToAddLiquidity = _numTokensSellToAddLiquidity();
        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddLiquidity;
        if (
            overMinTokenBalance &&
            !locker &&
            _sender != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddLiquidity;
            _swapAndLiquify(contractTokenBalance);
        }

        // transfer with fee logic ...
        bool takeFee = true;
        if (excludedFromFee[_sender] && excludedFromFee[_recipient]) {
            takeFee = false;
        }
        if (!takeFee) _disableFee();
        _transferWithFee(_sender, _recipient, _amount);
        if (!takeFee) _enableFee();
    }

    function _transferWithFee(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        // calculate fee ...
        (
            uint256 _supportFee,
            uint256 _taxFee,
            uint256 _liquidityFee
        ) = _calculateFees(_amount);
        uint256 _toTransferAmount = _amount -
            _supportFee -
            _taxFee -
            _liquidityFee;

        _balances[_recipient] += _toTransferAmount;
        rewardTotal += _taxFee;
        _balances[address(this)] += _liquidityFee;

        _takeSupport(_sender, _supportFee);
        emit Transfer(_sender, _recipient, _toTransferAmount);
    }

    function _reflectSender(address _sender, uint256 _amount) private {
        // substract sender balance
        (uint256 _rBalance, uint256 _rReward) = _getRValues(_sender, _amount);
        _balances[_sender] -= _rBalance;
        rewardTotal -= _rReward;
    }

    function _getRValues(address _sender, uint256 _amount)
        private
        view
        returns (uint256, uint256)
    {
        (uint256 persistBalance, uint256 rewardBalance) = _getBalances(_sender);
        uint256 total = persistBalance + rewardBalance;
        // split amount into parts
        uint256 rate = total / _amount;
        uint256 substructBalance = persistBalance / rate;
        uint256 substructReward = rewardBalance / rate;
        return (substructBalance, substructReward);
    }

    function _calculateFees(uint256 _amount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 amountToSupport = (_amount / percentageGranularity) *
            supportFee;
        uint256 amountToCharge = (_amount / percentageGranularity) * taxFee;
        uint256 amountToAddLiquidity = (_amount / percentageGranularity) *
            liquidityFee;
        return (amountToSupport, amountToCharge, amountToAddLiquidity);
    }

    function _maxTxAmount() private view returns (uint256) {
        return (_totalSupply / percentageGranularity) * maxTxAmountPercentage;
    }

    function _numTokensSellToAddLiquidity() private view returns (uint256) {
        return
            (_totalSupply / percentageGranularity) *
            numTokensSellToAddLiquidityPercentage;
    }

    function _disableFee() private {
        taxFeeOrigin = taxFee;
        liquidityFeeOrigin = liquidityFee;
        supportFeeOrigin = supportFeeOrigin;
        taxFee = 0;
        liquidityFee = 0;
        supportFee = 0;
    }

    function _enableFee() private {
        taxFee = taxFeeOrigin;
        liquidityFee = liquidityFeeOrigin;
        supportFee = supportFeeOrigin;
    }

    function _takeSupport(address _sender, uint256 _toBeTaken) private {
        _balances[supportWallet] += _toBeTaken;
        totalSupported += _toBeTaken;
        emit Transfer(_sender, supportWallet, _toBeTaken);
    }
}
