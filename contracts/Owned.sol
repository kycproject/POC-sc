pragma solidity ^0.4.11;

contract Owned {

    address public owner;
    address public developer;
    address public sysAccount;

    function Owned() public {
        owner = msg.sender;
        developer = msg.sender;
        sysAccount = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyDeveloper() {
        require(msg.sender == developer);
        _;
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setDeveloper(address _newDeveloper) public onlyOwner {
        developer = _newDeveloper;
    }

    function setSysAccount(address _newSysAccount) public onlyOwner {
        sysAccount = _newSysAccount;
    }

}
