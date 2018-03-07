pragma solidity ^0.4.18;

contract Question {

    struct QuestionStruct {
        address asker;
        address target;
        bytes32[] comments;
        uint token;
        mapping(address => bytes32) commentators;
    }

    mapping(bytes32 => QuestionStruct) internal questions;


    //Get information of this question
    function getQuestionInfo(bytes32 qusetionUid) public constant
    returns (address asker, address target, bytes32[] comments){
        QuestionStruct storage question = questions[qusetionUid];
        asker = question.asker;
        target = question.target;
        comments = question.comments;
    }
}
