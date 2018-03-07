pragma solidity ^0.4.18;

import "./Template.sol";

contract MockTemplate is Template {

  function MockTemplate() public {
      owner = msg.sender;
      defaultScore = 60;
      minTokenForAddQuestion = 0;
      minTokenForWatchComment = 0;
  }

  function getMinTokenForAddQuestion() public constant returns(uint) {
      return minTokenForAddQuestion;
  }

  //Get information of this question
  function getQuestionToken(bytes32 qusetionUid) public constant returns (uint){
      QuestionStruct storage question = questions[qusetionUid];
      return question.token;
  }

}
