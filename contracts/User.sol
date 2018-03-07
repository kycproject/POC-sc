pragma solidity ^0.4.18;

contract User {

    struct UserStruct {
        uint score;
        address[] friends;
        bytes32[] askQuestions;
        bytes32[] relateQuestions;
        bytes32[] comments;
        bytes32[] commentWatchings;
        address recommender;
        uint8 recommenderBonusTimes;
    }

    uint defaultScore;

    mapping(address => UserStruct) internal users;
    event GetFriendRelateQuestions(address userAddress, bytes32[] questions);

    function User() public {
        defaultScore = 60;
    }

    function getScore() public constant returns(uint score) {
        UserStruct storage user = users[msg.sender];
        uint userScore = user.score;
        if (userScore <= 0) {
            userScore = defaultScore;
        }
        //count friends with score
        uint friendScore = 0;
        uint friendCount = 0;
        for (uint8 i=0;i<user.friends.length;i++) {
            if (users[user.friends[i]].score>0) {
                friendScore += users[user.friends[i]].score;
                friendCount ++;
            }
        }
        if (friendCount > 0) {
            score = (userScore*7+(friendScore/friendCount)*3)/10;
        } else {
            score = userScore;
        }
        //The highest score can't exceed 99 points
        if (score > 99) {
            score = 99;
        }
    }

    function getUserScore(address userAddress) internal constant returns(uint) {
        UserStruct storage user = users[userAddress];
        uint userScore = user.score;
        if (userScore == 0) {
            userScore = defaultScore;
        }
        return userScore;
    }

    function getFriends() public constant returns(address[]) {
        UserStruct storage user = users[msg.sender];
        return user.friends;
    }

    function relateFriend(address friendAddress) public {
        require(msg.sender != friendAddress);
        UserStruct storage user = users[msg.sender];
        bool existFlag = false;
        for (uint i=0;i<user.friends.length;i++) {
            if (user.friends[i]==friendAddress) {
                existFlag = true;
            }
        }
        if (!existFlag) {
            user.friends.push(friendAddress);
            UserStruct storage friend = users[friendAddress];
            friend.friends.push(msg.sender);
        } else {
            //An existing relationship of friends
        }
    }

    function getFriendRelateQuestions() public returns(bytes32[]) {
        bytes32[] storage questions;
        UserStruct storage user = users[msg.sender];
        for (uint i=0;i<user.friends.length;i++) {
            address friendAddr = user.friends[i];
            UserStruct storage friend = users[friendAddr];
            bytes32[] memory friendQues = friend.askQuestions;
            for (uint j=0;j<friendQues.length;j++) {
                questions.push(friendQues[j]);
            }
        }
        GetFriendRelateQuestions(msg.sender, questions);
        return questions;
    }

    function transferAndCheckRecommender(address userAddress, uint amount) internal {
       uint recommenderBonus = 0;
       UserStruct storage user = users[userAddress];
       if (user.recommender != 0) {
          if (user.recommenderBonusTimes<5) {
            //The recommender will gain 50% of the total incomes of the first 5 times
            recommenderBonus = amount/2;
          } else if (user.recommenderBonusTimes<100) {
            //The recommender will gain 5% of the total incomes of the first 100 times
            recommenderBonus = amount/20;
          }
       }
       user.recommenderBonusTimes = user.recommenderBonusTimes+1;
       if(recommenderBonus>0) {
          user.recommender.transfer(recommenderBonus);
       }
       userAddress.transfer(amount-recommenderBonus);
    }

    function setRecommender(address _recommender) {
       require(users[msg.sender].recommender == 0);
       users[msg.sender].recommender = _recommender;
    }

}
