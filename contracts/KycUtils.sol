pragma solidity ^0.4.18;

library KycUtils {

    //This is a method to get unique ID
    function getUid(bytes32 salt) public constant returns(bytes32 uid) {
        bytes32 tiHash = keccak256(block.timestamp);
        bytes32 bnHash = block.blockhash(block.number);
        bytes32 seHash = keccak256(msg.sender);
        bytes32 saltHash = keccak256(salt);
        byte[128] memory mix;
        for (uint i=0;i<128;i++) {
            if (i<32) {
                mix[i] = tiHash[i];
            } else if (i<64) {
                mix[i] = bnHash[i-32];
            } else if (i<96) {
                mix[i] = seHash[i-64];
            } else {
                mix[i] = saltHash[i-96];
            }
        }
        uid = keccak256(mix);
    }

}
