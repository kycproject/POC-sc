pragma solidity ^0.4.18;

contract Comment {

    struct CommentStruct {
        address commentator;
        bytes32 questionUid;
        uint score;
        mapping(address => WatchingStruct) watchings;
    }

    struct WatchingStruct {
        address watching;
        uint token;
        uint8 currentStatus; // The status of watching; 1 init ; 2 approve; 3 disapprove
    }

    mapping(bytes32 => CommentStruct) internal comments;

    //Add one user to watchings list
    function addWatchToComment(bytes32 commentUid) internal {
        CommentStruct storage comment = comments[commentUid];
        require(comment.commentator != msg.sender);
        require(comment.watchings[msg.sender].watching == 0);
        comment.watchings[msg.sender].watching = msg.sender;
        comment.watchings[msg.sender].token = msg.value;
        comment.watchings[msg.sender].currentStatus = 1;
    }

}
