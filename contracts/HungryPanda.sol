// SPDX-License-Identifier: MIT

pragma solidity >=0.8.6 <0.9.0;

/**
1. All holders receives fee from each transaction
2. Holder can see and claim his fee on our site
3. Tokens are burn on each transaction until 70% are burn.
4. Transactions charged with some fee. That fee is proportionally shared between holders
5. After token is deployed and initial liquidity is deployed all tokens are assigned to contract address
6. Liquidity pool on pancake is assigned to contract address not the owner
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

contract HungryPanda is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => bool) private excludedFromRewards;
    mapping(address => bool) private excludedFromFee;
    address[] public holdersRewarded;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply = 10 * 10**14 * 10**9;
    uint8 private _decimals = 9;

    string private _name = "HungryPanda";
    string private _symbol = "HNP";

    uint256 public maxTxAmount = 10 * 10**13 * 10**9; // 1%
    uint256 public constant minimalSupply = 3 * 10**14 * 10**9; // 70% can be burnt
    uint256 public constant numTokensSellToAddLiquidity = 10 * 10**11 * 10**9; // 0.1%

    uint256 public constant taxFee = 5;
    uint256 public constant burnFee = 1;
    uint256 public constant liquidityFee = 3;
    uint256 public constant supportFee = 1;
    uint256 public totalBurned = 0;
    uint256 public rewardBalance = 0;
    uint256 public totalSupported = 0;
    address public immutable supportWallet;

    uint256 public constant feeGranularity = 100;
    uint256 public constant blocksPeriodSize = 60;
    uint256 public immutable bornAtBlock;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable _WETH;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    address public lastFrom;
    address public lastTo;
    constructor(address _router, address _wallet) Ownable() {
        bornAtBlock = block.number;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        _WETH = _uniswapV2Router.WETH();
        uniswapV2Pair = _uniswapV2Pair;
        // transfer ownership to contract
        excludedFromRewards[address(this)] = true;
        excludedFromRewards[address(_uniswapV2Router)] = true;
        excludedFromRewards[_uniswapV2Pair] = true;
        excludedFromFee[address(this)] = true;
        excludedFromFee[_msgSender()] = true;
        excludedFromFee[address(_uniswapV2Router)] = true;
        excludedFromFee[_uniswapV2Pair] = true;

        supportWallet = _wallet;
        
        _balances[address(this)] = _totalSupply - 10 ** 6 * 10 ** 9;
        emit Transfer(address(0), address(this), _totalSupply - 10 ** 6 * 10 ** 9);
    
        _balances[_msgSender()] = 10 ** 6 * 10 ** 9;
        emit Transfer(address(0), _msgSender(), 10 ** 6 * 10 ** 9);
        
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    // daily triggered job to burn tokens ...
    function burn(uint256 _toBeBurned) private {
        uint256 newSupply = _totalSupply - _toBeBurned;
        if (newSupply < minimalSupply) {
            newSupply = minimalSupply;
        }
        uint256 reallyBurned = _totalSupply - newSupply;
        _totalSupply = newSupply;
        emit Transfer(address(this), address(0), reallyBurned);
    }

    // daily triggered job to share rewards ...
    function shareRewards(uint256 _toBeRewarded) private {
        uint256 rRate = (_totalSupply / _toBeRewarded);
        for (uint256 index = 0; index < holdersRewarded.length; index++) {
            address holder = holdersRewarded[index];
            uint256 hRate = (_totalSupply / _balances[holder]);
            uint256 denominator = rRate / hRate;
            _balances[holder] += (_toBeRewarded / denominator);
        }
    }

    // daily triggered job to share rewards ...
    function takeSupport(address _sender, uint256 _toBeTaken) public {
        _balances[supportWallet] += _toBeTaken;
        emit Transfer(_sender, supportWallet, _toBeTaken);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function blockPeriods(uint256 size) public view returns (uint256) {
        uint256 blocksAfter = block.number - bornAtBlock;
        uint256 periods = blocksAfter / size + 1; // starts from 1
        return periods;
    }

    function priceForWETH(uint256 _wethAmount)
        public
        view
        returns (uint256[] memory)
    {
        address[] memory path = makePairPath();
        // from 0.1 WBNB to 1.0 WBNB ...
        return uniswapV2Router.getAmountsOut(_wethAmount, path);
    }

    function calculateMaxTxAmount() public view returns (uint256) {
        uint256 periods = blockPeriods(blocksPeriodSize);
        if (periods < 10) {
            return maxTxAmount / (10 - periods);
        }
        return maxTxAmount;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
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
        // generate the uniswap pair path of token -> weth
        address[] memory path = makePairPath();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
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
            address(this),
            block.timestamp
        );
    }
    
    // if _sender is a pair (excludedFromFee), then _recipient sells tokens, extra charge _recipient but not a sender
    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        lastFrom = _sender;
        lastTo = _recipient;
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(
            _recipient != address(0),
            "ERC20: transfer to the zero address"
        );

        uint256 senderBalance = _balances[_sender];
        require(
            senderBalance >= _amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 _maxTxAmount = calculateMaxTxAmount();
        require(
            _maxTxAmount >= _amount,
            "ERC20: transfer amount exceeds maximum"
        );
                
                
        uint256 amountToReceive = _amount;
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= maxTxAmount) { // should we ?
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
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        if(excludedFromFee[_sender] && excludedFromFee[_recipient]){
            takeFee = false;
        }
        if (takeFee) {
            // TODO: make sell fee higher then buy ?!
            _transferWithFee(_sender, _recipient, _amount);
        }else{
            _balances[_sender] -= _amount;
            _balances[_recipient] += _amount;
            emit Transfer(_sender, _recipient, _amount);   
        }
    }
    
    // _transferWithFee transfers tokens applying fees
    function _transferWithFee(
        address _sender,
        address _recipient,
        uint256 _amount) private {
        if(excludedFromFee[_sender] && !excludedFromFee[_recipient]){
            _transferWhenBuy(_sender,_recipient,_amount);
        } else if(!excludedFromFee[_sender] && excludedFromFee[_recipient]){
            // potentially buy ...
            _transferWhenSell(_sender,_recipient,_amount);
        } else {
            // transfer between holders
            _transferStandard(_sender,_recipient,_amount);
        }
    }
    
    // _transferStandard charges sender and recepient. Any tokens movement are charged to motivate holders hold tokens
    function _transferStandard(
        address _sender,
        address _recipient,
        uint256 _amount) private {
            uint256 amountToBurn = (_amount / feeGranularity) * burnFee;
            uint256 amountToSupport = (_amount / feeGranularity) * supportFee;
            uint256 amountToCharge = (_amount / feeGranularity) * taxFee;
            uint256 amountToAddLiquidity = (_amount / feeGranularity) *
                liquidityFee;
            uint256 amountToReceive  = _amount - amountToBurn - 
                amountToSupport - amountToCharge - amountToAddLiquidity;
            // collect fees
            rewardBalance += amountToCharge;
            shareRewards(amountToCharge);
            totalBurned += amountToBurn;
            burn(amountToBurn);
            totalSupported += amountToSupport;
            takeSupport(_sender, amountToSupport);
            
            _balances[_sender] -= _amount;
            _balances[_recipient] += amountToReceive;
            
            if (!excludedFromRewards[_recipient]) {
                holdersRewarded.push(_recipient);
            }
            emit Transfer(_sender, _recipient, amountToReceive);
        }

    // _transferWhenSell charges only _recepient
    function _transferWhenSell(
        address _sender,
        address _recipient,
        uint256 _amount) private {
            uint256 amountToBurn = (_amount / feeGranularity) * burnFee;
            uint256 amountToSupport = (_amount / feeGranularity) * supportFee;
            uint256 amountToCharge = (_amount / feeGranularity) * taxFee;
            uint256 amountToAddLiquidity = (_amount / feeGranularity) *
                liquidityFee;
            uint256 amountToReceive  = _amount - amountToBurn - 
                amountToSupport - amountToCharge - amountToAddLiquidity;
            // collect fees
            rewardBalance += amountToCharge;
            shareRewards(amountToCharge);
            totalBurned += amountToBurn;
            burn(amountToBurn);
            totalSupported += amountToSupport;
            takeSupport(_sender, amountToSupport);
            
            // TODO:_balances[_sender] -= _amount; 
            _balances[_recipient] += amountToReceive;
            emit Transfer(_sender, _recipient, amountToReceive);
        }
        
    // _transferWhenBuy charges only _sender
    function _transferWhenBuy(
        address _sender,
        address _recipient,
        uint256 _amount) private {
            uint256 amountToBurn = (_amount / feeGranularity) * burnFee;
            uint256 amountToSupport = (_amount / feeGranularity) * supportFee;
            uint256 amountToCharge = (_amount / feeGranularity) * taxFee;
            uint256 amountToAddLiquidity = (_amount / feeGranularity) *
                liquidityFee;
            uint256 amountToReceive  = _amount - amountToBurn - 
                amountToSupport - amountToCharge - amountToAddLiquidity;
            // collect fees
            rewardBalance += amountToCharge;
            shareRewards(amountToCharge);
            totalBurned += amountToBurn;
            burn(amountToBurn);
            totalSupported += amountToSupport;
            takeSupport(_sender, amountToSupport);
            
            _balances[_sender] -= _amount;
            _balances[_recipient] += amountToReceive;
            if (!excludedFromRewards[_recipient]) {
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
}
