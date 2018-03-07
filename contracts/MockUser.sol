pragma solidity ^0.4.18;

import "./User.sol";

contract MockUser is User {

    function MockUser() public {
        defaultScore = 60;
    }

    function setScore(address userAddress, uint _score) public {
        users[userAddress].score = _score;
    }

    function getRecommender() public constant returns(address) {
       return users[msg.sender].recommender;
    }

    function mockTransferAndCheckRecommender(address userAddress, uint amount) public payable {
        transferAndCheckRecommender(userAddress, amount);
    }

    function setRecommenderBonusTimes(address userAddress, uint8 times) public {
        users[userAddress].recommenderBonusTimes = times;
    }

    function getRecommenderBonusTimes(address userAddress) public constant returns(uint8) {
       return users[userAddress].recommenderBonusTimes;
    }

}
