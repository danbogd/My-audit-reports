pragma solidity ^0.4.25;

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract MinValue is owned{

    address[] private receiversMinValueAddr; //array contenente gli indirizzi riceventi di MinValore
    uint private nReceivers;
    
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public burned;
    uint public percentage = 25; //x100 | 25(default) it can be changed

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event NewPercentageSetted(address indexed from, uint newPercentage);
    event NewReceiver(address indexed from, address _ricevente);
    event NewReceiverByIndex(uint _index, address _ricevente);
    
    /**
     * Costruttore
     *
     * Inizializzo nel costruttore i dati del token.
     */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        address _ricevente
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;  
        name = tokenName;
        symbol = tokenSymbol;
        nReceivers=0;
        receiversMinValueAddr.push(_ricevente);
        burned = 0;
    }
    
    function setNewReceiverAddr(address _ricevente) onlyOwner public{
        require(_ricevente != 0x0);
        receiversMinValueAddr.push(_ricevente);
        nReceivers++; //Aggiorno quanti indirizzi riceventi ci sono
        emit NewReceiver(msg.sender, _ricevente); //notifico su blockchain che è stato settato un nuovo ricevente
    }

    function setReceiverAddrByIndex(uint _index, address _ricevente) onlyOwner public{
        require(_ricevente != 0x0);
        require (_index <= nReceivers);    
        receiversMinValueAddr[_index]=_ricevente;
        emit NewReceiverByIndex(_index, _ricevente);
    }
    
    function setNewPercentage(uint _newPercentage) onlyOwner public{ //solo il proprietario
        require(_newPercentage <= 100);
        require(_newPercentage >= 0);
        percentage = _newPercentage;
        emit NewPercentageSetted(msg.sender, _newPercentage); //notifico su blockchain l'avvenuta modifica della percentuale
    }


    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function _calcPercentage(uint _value, uint _percentage) internal constant returns(uint){
        return (_value*_percentage)/100;
    }

    function _burnPercentageAndTransfer(uint _value, address _sender, address _to) internal {
        uint toBurn = _calcPercentage(_value, percentage); //calcolo una volta sola in tutta la funzione per sicurezza
        //perchè potrebbe accadere che una funzione chiamata venga minata ed approvata prima di un'altra e ciò causerebbe comportamento insolito
        //ed incongruenze di valori.
        approve(_sender, _value);
        burnFrom(_sender, toBurn);
        _transfer(_sender, _to, _value-toBurn);
    }
    
    function existReceiver(address _ricevente) public constant returns(bool){
        bool check = false;
        for(uint i = 0; i <= nReceivers; i++){
            if(receiversMinValueAddr[i] == _ricevente)
                check = true;
        }
        return check;
    }
    
    function getReceivers() public constant returns(uint){
        return receiversMinValueAddr.length;
    }

    function getReceiverAddress (uint256 _number) public constant returns(address _address){
        return receiversMinValueAddr[_number];
    }
    
    function transfer(address _to, uint256 _value) public {
        if (existReceiver(_to)){
            _burnPercentageAndTransfer(_value, msg.sender, _to);
        }
        else{
            _transfer(msg.sender, _to, _value);
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)  public returns (bool success) {
       
        tokenRecipient spender = tokenRecipient(_spender);
       
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);  
        balanceOf[msg.sender] -= _value; 
        totalSupply -= _value;
        burned += _value; //contenutore dei token bruciati;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                
        require(_value <= allowance[_from][msg.sender]);    
        balanceOf[_from] -= _value;                         
        allowance[_from][msg.sender] -= _value;             
        totalSupply -= _value;                              // Aggiorno
        burned += _value;
        emit Burn(_from, _value);
        return true;
    }
}

contract MinValueToken is owned, MinValue {

    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen); //notifico il "congelamento"

    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        address _ricevente
    ) MinValue(initialSupply, tokenName, tokenSymbol, _ricevente) public {}

    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value > balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        emit Transfer(_from, _to, _value);
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

}
