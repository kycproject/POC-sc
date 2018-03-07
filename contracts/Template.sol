pragma solidity ^0.4.18;

import "./Owned.sol";
import "./User.sol";
import "./Question.sol";
import "./Comment.sol";

contract Template is Owned, User, Question, Comment {

    uint minTokenForAddQuestion;
    uint minTokenForWatchComment;
    event AddQuestion(address from, address target, bytes32 questionUid);
    event AddComment(address from, bytes32 questionUid, bytes32 commentUid);


    function Template() public {
        owner = msg.sender;
        defaultScore = 60;
        minTokenForAddQuestion = 0;
        minTokenForWatchComment = 0;
    }

    function setDefaultScore(uint8 score) onlyOwner public {
        defaultScore = score;
    }

    function setMinTokenForAddQuestion(uint minToken) onlyOwner public {
        minTokenForAddQuestion = minToken;
    }

    function setMinTokenForWatchComment(uint minToken) onlyOwner public {
        minTokenForWatchComment = minToken;
    }

    function addQuestion(address target, bytes32 questionUid) public payable returns(bytes32) {
        require(target != msg.sender);
        require(questions[questionUid].asker==0);
        require(msg.value>=minTokenForAddQuestion);
        // add new question to questions list
        questions[questionUid].asker = msg.sender;
        questions[questionUid].target = target;
        questions[questionUid].token=msg.value;
        // Add questionUid to asker's struct
        UserStruct storage asker = users[msg.sender];
        asker.askQuestions.push(questionUid);
        // Add questionUid to target's struct
        UserStruct storage targetUser = users[target];
        targetUser.relateQuestions.push(questionUid);
        AddQuestion(msg.sender, target, questionUid);
        return questionUid;
    }

    function addComment(bytes32 questionUid, bytes32 commentUid) public returns(bytes32) {
        // cannot comment by asker or target
        require(question.asker!=msg.sender);
        require(question.target!=msg.sender);
        QuestionStruct storage question = questions[questionUid];
        // cannot repeat comment
        require(question.commentators[msg.sender]==0);
        CommentStruct storage comment = comments[commentUid];
        require(comment.commentator==0);
        // add commentUid to question's struct
        question.comments.push(commentUid);
        // add new comment to comments list
        comment.commentator = msg.sender;
        comment.questionUid = questionUid;
        //add comment to user's comments
        UserStruct storage user = users[msg.sender];
        user.comments.push(commentUid);
        uint userScore = getUserScore(msg.sender);
        comment.score = userScore;

        // get Token: BT × 50% x UR x 1%
        uint getToken = question.token*userScore*5/1000;
        question.token = question.token - getToken;
        transferAndCheckRecommender(msg.sender, getToken);
        // add friendship
        relateFriend(question.target);

        AddComment(msg.sender, questionUid, commentUid);
        return commentUid;
    }

    function watch(bytes32 commentUid) payable public {
        require(msg.value>=minTokenForWatchComment);
        addWatchToComment(commentUid);
        //add commentUid to user's commentWatchings
        UserStruct storage user = users[msg.sender];
        user.commentWatchings.push(commentUid);
    }

    //Approve of one comment
    function approve(bytes32 commentUid) public payable {
        CommentStruct storage comment = comments[commentUid];
        WatchingStruct storage watching = comment.watchings[msg.sender];
        require(watching.currentStatus == 1);
        watching.currentStatus = 2;
        QuestionStruct storage question = questions[comment.questionUid];
        //affect the score of comment
        UserStruct storage approveUser = users[msg.sender];
        uint approveUserScore = getUserScore(msg.sender);
        uint commentScore = comment.score + (100-comment.score)*approveUserScore/200;
        if (commentScore>99) {
            commentScore = 99;
        }
        comment.score = commentScore;
        //affect the score of comment user
        UserStruct storage commentUser = users[comment.commentator];
        uint commentCount = commentUser.comments.length;
        uint preCommentUserScore = getUserScore(comment.commentator);
        uint commentUserScore = (preCommentUserScore*commentCount + commentScore)/(commentCount+1);
        if (commentUserScore > 99) {
            commentUserScore = 99;
        } else if (commentUserScore < 1) {
            commentUserScore = 1;
        }
        commentUser.score = commentUserScore;

        //40% to asker
        uint token40 = watching.token*40/100;
        transferAndCheckRecommender(question.asker, token40);
        //40% to commentator
        transferAndCheckRecommender(comment.commentator, token40);
        //10% to target
        uint token10 = watching.token*10/100;
        transferAndCheckRecommender(question.target, token10);
        //10% to approver
        msg.sender.transfer(token10);
    }

    //Disapprove of one comment
    function disapprove(bytes32 commentUid) public {
        CommentStruct storage comment = comments[commentUid];
        WatchingStruct storage watching = comment.watchings[msg.sender];
        require(watching.currentStatus == 1);
        watching.currentStatus = 3;
        QuestionStruct storage question = questions[comment.questionUid];
        //affect the score of comment
        UserStruct storage approveUser = users[msg.sender];
        uint commentScore = comment.score - approveUser.score/2;
        if (commentScore<1) {
            commentScore = 1;
        }
        comment.score = commentScore;
        //affect the score of comment user
        UserStruct storage commentUser = users[comment.commentator];
        uint commentCount = commentUser.comments.length;
        uint commentUserScore = (commentUser.score*commentCount + commentScore)/(commentCount+1);
        if (commentUserScore > 99) {
            commentUserScore = 99;
        } else if (commentUserScore < 1) {
            commentUserScore = 1;
        }
        commentUser.score = commentUserScore;

        //10% to asker
        uint token10 = watching.token*10/100;
        transferAndCheckRecommender(question.asker, token10);
        //10% to commentator
        transferAndCheckRecommender(comment.commentator, token10);
        //70% to system
        uint token70 = watching.token*70/100;
        sysAccount.transfer(token70);
        //10% to disapprover
        msg.sender.transfer(token10);
    }
}
