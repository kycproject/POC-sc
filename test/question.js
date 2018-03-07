const MockTemplate = artifacts.require('./MockTemplate.sol')

const { assertFail, assertEqual, assertArrayEqual, assertArrayLength, isBigNumber} = require('./utils.js')
const BigNumber = web3.BigNumber
var crypto = require('crypto')

contract('Question', accounts => {
    const acc1 = accounts[0]
    const acc2 = accounts[1]
    const acc3 = accounts[2]
    //console.log(web3.eth.getBalance(acc1))

    let template
    const minTokenForAddQuestion = 10000;
    it('deploy', async () => {
        template = await MockTemplate.new()
    })

    //set minTokenForAddQuestion
    it('setMinTokenForAddQuestion', async () => {
        //can only be set by the owner of the contract
        try {
            await template.setMinTokenForAddQuestion(minTokenForAddQuestion,{from:acc2})
            assert.fail('should have thrown error before')
        } catch (error) {
            //
        }
        await template.setMinTokenForAddQuestion(minTokenForAddQuestion,{from:acc1})
        assertEqual(await template.getMinTokenForAddQuestion(), minTokenForAddQuestion)
    })

    it('addQuestion', async () => {
        //acc1 ask question about acc2
        const questionUid = '1212'
        await template.addQuestion(acc2, questionUid, {from: acc1, value:minTokenForAddQuestion})
        const questionInfo1 = await template.getQuestionInfo(questionUid)
        assertEqual(questionInfo1[0], acc1)
        assertEqual(questionInfo1[1], acc2)
    })

    //cannot be lower than the minimum limit for asking a question.
    it('checkMinTokenForAddQuestion', async () => {
        const questionUid = '12123'
        try {
            await template.addQuestion(acc2, questionUid, {from: acc1, value:5000})
            assert.fail('should have thrown error before')
        } catch (error) {

        }
    })

    //cannot ask question by repeat questionUid
    it('checkAddQuestionRepeatedUid', async () => {
        //repeat questionUid
        const questionUid = '1212'
        try {
            await template.addQuestion(acc3, questionUid, {from: acc2, value:minTokenForAddQuestion})
            assert.fail('should have thrown error before')
        } catch (error) {
            //cannot ask question by repeat questionUid
        }
        const questionInfo2 = await template.getQuestionInfo(questionUid)
        assertEqual(questionInfo2[0], acc1)
        assertEqual(questionInfo2[1], acc2)

    })

    //cannot ask question about yourself
    it('checkAddQuestionForYourself', async () => {
        const questionUid = '1212345'
        try {
            await template.addQuestion(acc2, questionUid, {from: acc2, value:minTokenForAddQuestion})
            assert.fail('should have thrown error before')
        } catch (error) {
            //cannot ask question about yourself
        }
    })



})
