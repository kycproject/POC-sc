const MockTemplate = artifacts.require('./MockTemplate.sol')

const { assertFail, assertEqual, assertArrayEqual, assertArrayLength, isBigNumber} = require('./utils.js')
const BigNumber = web3.BigNumber
var crypto = require('crypto')

contract('AddComment', accounts => {
    const acc1 = accounts[0]
    const acc2 = accounts[1]
    const acc3 = accounts[2]
    const acc4 = accounts[3]
    //console.log(web3.eth.getBalance(acc1))

    let template
    const minTokenForAddQuestion = 10000;
    const questionUid = '1212'
    it('deploy', async () => {
        template = await MockTemplate.new()
        await template.setMinTokenForAddQuestion(minTokenForAddQuestion,{from:acc1})
        //acc1 ask question about acc2
        await template.addQuestion(acc2, questionUid, {from: acc1, value:minTokenForAddQuestion})
    })

    const commentUid = '1'
    //comment question
    it('addComment', async () => {
        await template.addComment(questionUid, commentUid, {from:acc3})
    })

    //cannot comment on your questions or questions about yourself
    it('checkAddCommentForYourself', async () => {
        try {
            await template.addComment(questionUid, '12', {from:acc1})
            assert.fail('should have thrown error before')
        } catch(error) {
            //cannot repeat set recommender
        }
        try {
            await template.addComment(questionUid, '123', {from:acc2})
            assert.fail('should have thrown error before')
        } catch(error) {
            //cannot repeat set recommender
        }
    })

    //cannot repeat a review of a problem
    it('checkAddCommentRepeatedUid', async () => {
        try {
            await template.addComment(questionUid, '1234', {from:acc3})
            assert.fail('should have thrown error before')
        } catch(error) {
            //cannot repeat set recommender
        }
    })

    //cannot to use repeated commentUid
    it('checkAddCommentRepeatedUid', async () => {
        try {
            await template.addComment(questionUid, commentUid, {from:acc3})
            assert.fail('should have thrown error before')
        } catch(error) {
            //cannot repeat set recommender
        }
    })

    //check comment token
    it('checkAddCommentToken', async () => {
        //const balance3 = web3.eth.getBalance(acc3)
        const preToken = await template.getQuestionToken(questionUid)
        const userScore = await template.getScore({from:acc3})
        await template.addComment(questionUid, '12345', {from:acc3})
        const leftToken = await template.getQuestionToken(questionUid)
        assertEqual(leftToken, preToken-preToken*userScore*5/1000)

    })

})

contract('WatchComment', accounts => {
    const acc1 = accounts[0]
    const acc2 = accounts[1]
    const acc3 = accounts[2]
    const acc4 = accounts[3]
    const acc5 = accounts[4]
    const acc6 = accounts[5]
    const acc7 = accounts[6]
    //console.log(web3.eth.getBalance(acc1))

    let template
    const minTokenForAddQuestion = 10000;
    const minTokenForWatchComment = 10000
    const questionUid = '1212'
    const commentUid = '1'
    it('deploy', async () => {
        template = await MockTemplate.new()
        await template.setMinTokenForAddQuestion(minTokenForAddQuestion,{from:acc1})
        await template.setMinTokenForWatchComment(minTokenForWatchComment)
        await template.setMinTokenForWatchComment(minTokenForWatchComment)
        await template.setSysAccount(acc7)
        //acc1 ask question about acc2
        await template.addQuestion(acc2, questionUid, {from: acc1, value:minTokenForAddQuestion})
        //acc3 comment this question
        await template.addComment(questionUid, commentUid, {from:acc3})
    })

    //watch comment
    it('checkWatchComment', async () => {
        try {
            await template.watch(commentUid, {from:acc4, value:5000})
            assert.fail('should have thrown error before')
        } catch (error) {
            //cannot be lower than the minimum limit
        }
        try {
            await template.watch(commentUid, {from:acc3, value:10000})
            assert.fail('should have thrown error before')
        } catch (error) {
            //cannot watch the comment of yourself
        }
        await template.watch(commentUid, {from:acc4, value:10000})

    })

    //approve comment
    it('checkApproveComment', async () => {
        try {
            await template.approve(commentUid, {from:acc5})
            assert.fail('should have thrown error before')
        } catch (error) {
            //Only after watching can you approve the comment
        }
        //asker:40% commentator:40% target:10% approver:10%
        const askerBalance1 = new BigNumber(web3.eth.getBalance(acc1))
        const targetBalance1 = new BigNumber(web3.eth.getBalance(acc2))
        const commentatorBalance1 = new BigNumber(web3.eth.getBalance(acc3))
        await template.watch(commentUid, {from:acc5, value:10000})
        await template.approve(commentUid, {from:acc5})
        const askerBalance2 = web3.eth.getBalance(acc1)
        const targetBalance2 = web3.eth.getBalance(acc2)
        const commentatorBalance2 = web3.eth.getBalance(acc3)
        assertEqual(askerBalance2, askerBalance1.plus(4000))
        assertEqual(commentatorBalance2, commentatorBalance1.plus(4000))
        assertEqual(targetBalance2, targetBalance1.plus(1000))

        try {
            await template.approve(commentUid, {from:acc5})
            assert.fail('should have thrown error before')
        } catch (error) {
            //cannot repeat approve
        }

    })

    //disapprove comment
    it('checkDisapproveComment', async () => {
        try {
            await template.disapprove(commentUid, {from:acc6})
            assert.fail('should have thrown error before')
        } catch (error) {
            //Only after watching can you disapprove the comment
        }
        //asker: 10% commentator:10% system:70% disapprover:10%
        const askerBalance1 = new BigNumber(web3.eth.getBalance(acc1))
        const commentatorBalance1 = new BigNumber(web3.eth.getBalance(acc3))
        const sysBalance1 = new BigNumber(web3.eth.getBalance(acc7))
        await template.watch(commentUid, {from:acc6, value:10000})
        await template.disapprove(commentUid, {from:acc6})
        const askerBalance2 = web3.eth.getBalance(acc1)
        const commentatorBalance2 = web3.eth.getBalance(acc3)
        const sysBalance2 = web3.eth.getBalance(acc7)
        assertEqual(askerBalance2, askerBalance1.plus(1000))
        assertEqual(commentatorBalance2, commentatorBalance1.plus(1000))
        assertEqual(sysBalance2, sysBalance1.plus(7000))

        try {
            await template.disapprove(commentUid, {from:acc6})
            assert.fail('should have thrown error before')
        } catch (error) {
            //cannot repeat disapprove
        }

    })




})
