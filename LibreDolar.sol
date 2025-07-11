// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// Interfaz IERC20 simplificada
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Implementación básica ERC20
contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: allowance menor a substract");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    
    // Funciones internas
    
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transferencia desde cero");
        require(to != address(0), "ERC20: transferencia a cero");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: saldo insuficiente");
        
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint a cero");
        
        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn de cero");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn mayor que saldo");
        
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        
        _totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve de cero");
        require(spender != address(0), "ERC20: approve a cero");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if(currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: allowance insuficiente");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

// Extensión burnable del token
abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// Contrato principal con comisión modificable y pausible
contract LibreDolar is ERC20Burnable {
    address public feeCollector;
    uint256 public feePercent; // comision en base 10000 (ej: 1 = 0.01%)
    bool public feeActive;
    address public owner;

    event FeeCollectorChanged(address indexed oldCollector, address indexed newCollector);
    event FeePercentChanged(uint256 oldFee, uint256 newFee);
    event FeeActiveChanged(bool oldState, bool newState);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _feeCollector) ERC20("LibreDolar", "$LD") {
        require(_feeCollector != address(0), "feeCollector no puede ser cero");
        feeCollector = _feeCollector;
        feePercent = 1; // 0.01%
        feeActive = true;
        owner = _msgSender();
        _mint(msg.sender, 1_000_000_000 * 10 ** decimals());
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner() {
        require(_msgSender() == owner, "Solo owner puede ejecutar");
        _;
    }

    // Permite transferir la propiedad del contrato
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "nuevo owner no puede ser cero");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Cambiar feeCollector
    function setFeeCollector(address newCollector) external onlyOwner {
        require(newCollector != address(0), "Nueva direccion no puede ser cero");
        emit FeeCollectorChanged(feeCollector, newCollector);
        feeCollector = newCollector;
    }

    // Cambiar porcentaje de comisión, máximo 10% (1000 base 10000)
    function setFeePercent(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Comision max 10%");
        emit FeePercentChanged(feePercent, newFee);
        feePercent = newFee;
    }

    // Activar o desactivar comisión
    function setFeeActive(bool active) external onlyOwner {
        emit FeeActiveChanged(feeActive, active);
        feeActive = active;
    }

    // Override _transfer para cobrar comisión si está activa
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        require(from != address(0), "ERC20: transferencia desde cero");
        require(to != address(0), "ERC20: transferencia a cero");
        require(amount > 0, "ERC20: transferencia cero");

        if (feeActive && feePercent > 0 && from != feeCollector && to != feeCollector) {
            // Evitamos comisión en transferencias hacia o desde feeCollector
            uint256 fee = (amount * feePercent) / 10000;
            require(amount > fee, "ERC20: monto menor o igual a la comision");
            uint256 amountAfterFee = amount - fee;

            super._transfer(from, feeCollector, fee);
            super._transfer(from, to, amountAfterFee);
        } else {
            super._transfer(from, to, amount);
        }
    }
}
