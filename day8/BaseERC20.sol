// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseERC20 {
    // 代币名称
    string public name;
    // 代币符号
    string public symbol; 
    // 返回token使用的小数点后几位
    uint8 public decimals;
    // 代币发行总量
    uint256 public totalSupply;
    // 保存着每个地址对应的余额
    mapping(address => uint256) balances;
    // 保存着某个地址A允许另一个地址B可操作的金额
    mapping (address => mapping (address => uint256)) allowances;

    // 定义Transfer转账事件
    event Transfer(address indexed from, address indexed to, uint256 amount);
    // 定义Approva批准事件
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    error BaseERC20NotEnoughAllowance();

    constructor() public {
        name = "BaseERC20";
        symbol = "BERC20";
        // token小数位最多18位
        decimals = 18;
        // 供应总量 = 供应量 * 1 eth = 100000000 * 10^18
        totalSupply = 100000000 * 10 ** uint256(decimals);
        // 合约部署的时候，设置这个地址对应的代币供应量
        balances[msg.sender] = totalSupply;
    }

    // 获取指定owner地址对应的代币余额
function balanceOf(address account) public view virtual returns (uint256) {
        return balances[account];
    }

    // 查询某个owner授权委托人允许的转账数量
    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowances[_owner][_spender];
    }

    // 向指定地址转账
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // 校验地址是不是0, address如果没有传递地址就是默认就是0
        require(_to != address(0), "BaseERC20: invalid sender");
        
        // 检验发送者账户token数量是否足够
        require(balances[msg.sender] > _value, "ERC20: transfer amount exceeds balance");
        
        // 扣除发送者账户token余额
        balances[msg.sender] -= _value;
        // 增加接收者账户token余额
        balances[_to] += _value;

        // 向区块链发送一个转账事件
        emit Transfer(msg.sender, _to, _value);

        return true;   
    }

    // 委托人将from用户转移一定数量token到to账户
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // 校验地址是不是0, address如果没有传递地址就是默认就是0
        require((_from != address(0) && _to != address(0)), "BaseERC20: invalid sender or recepient address");
        
        // 检验发送者账户token数量是否足够
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");

        // 校验token委托方针对from用户剩余被批准的token数量
        uint256 allowance = allowance(_from, msg.sender);
        require(allowance >= _value, "ERC20: transfer amount exceeds allowance");
        // 转移之后from的token数量扣减
        balances[_from] -= _value;
        // 扣减spender剩余的可转账token数量
        allowances[_from][msg.sender] -= _value;
        // 转移之后token数量的余额增加
        balances[_to] += _value;
        // 向区块链发送一个转账事件
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    // 是授权的approve的调用方，即为批准方，也就是消息发送者，更新spender剩余可转账余额
    function approve(address spender, uint256 value) public returns (bool success) {
        allowances[msg.sender][spender] = value;
        // 向区块链发送一个批准事件
        emit Approval(msg.sender, spender, value);
        return true;
    }

}