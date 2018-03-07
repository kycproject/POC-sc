const MockUser = artifacts.require('./MockUser.sol')
const { assertFail, assertEqual, assertArrayEqual, assertArrayLength, isBigNumber} = require('./utils.js')
const BigNumber = web3.BigNumber
var crypto = require('crypto')

contract('MockUser', accounts => {
    const acc1 = accounts[0]
    const acc2 = accounts[1]
    const acc3 = accounts[2]
    //console.log(web3.eth.getBalance(acc1))

    let user
    it('deploy', async () => {
        user = await MockUser.new()
        // check init params
        assertEqual(await user.getScore(), 60)
    })

    it('setRecommender', async () => {
        assertEqual(await user.getRecommender({from: acc1}), 0x0)
        await user.setRecommender(acc2, {from : acc1})
        assertEqual(await user.getRecommender({from: acc1}), acc2)
        try {
          await user.setRecommender(acc3, {from : acc1})
          assert.fail('should have thrown error before')
        } catch(error) {
          //cannot repeat set recommender
        }
        assertEqual(await user.getRecommender({from: acc1}), acc2)
    })

    it('relateFriend', async () =>{
        //add friendship between acc1 and acc2
        await user.relateFriend(acc2, {from : acc1})
        assertArrayEqual(await user.getFriends({from : acc1}), [acc2])
        await user.relateFriend(acc1, {from : acc2})
        assertArrayLength(await user.getFriends({from : acc1}), 1)
    })

    it('getScore', async () => {
        const score1 = 80
        const score2 = 50
        await user.setScore(acc1, score1)
        assertEqual(await user.getScore({from: acc1}), score1)
        await user.setScore(acc2, score2)
        //calculate user score
        const calculateScore2 = score2*0.7+score1*0.3
        assertEqual(await user.getScore({from: acc2}), calculateScore2)
        //Adding a friend with an empty score does not affect the current user score
        await user.relateFriend(acc3, {from : acc2})
        assertEqual(await user.getScore({from: acc2}), calculateScore2)
    })

    it('transferAndCheckRecommender', async () =>{
        //web3.eth.sendTransaction({from : acc1, to : acc2, value: 10e+18})
        //console.log(web3.eth.getBalance(user.address))
        //set acc3 as the recommender of acc2
        await user.setRecommender(acc3, {from : acc2})
        const balance21 = web3.eth.getBalance(acc2)
        const balance31 = web3.eth.getBalance(acc3)
        const amount = 10000
        //The 50% of the token is transfer to the recommender in the first 5 times
        await user.mockTransferAndCheckRecommender(acc2, amount, {from : acc1, value: 10000})
        const after21 = new BigNumber(balance21).plus(amount/2)
        const after31 = new BigNumber(balance31).plus(amount/2)
        assertEqual(web3.eth.getBalance(acc2), after21)
        assertEqual(web3.eth.getBalance(acc3), after31)
        assertEqual(await user.getRecommenderBonusTimes(acc2), 1)
        //The 5% of the token is transfer to the recommender in the first 100 times
        await user.setRecommenderBonusTimes(acc2, 5);
        const balance22 = web3.eth.getBalance(acc2)
        const balance32 = web3.eth.getBalance(acc3)
        await user.mockTransferAndCheckRecommender(acc2, amount, {from : acc1, value: 10000})
        const after22 = new BigNumber(balance22).plus(amount*19/20)
        const after32 = new BigNumber(balance32).plus(amount/20)
        assertEqual(web3.eth.getBalance(acc2), after22)
        assertEqual(web3.eth.getBalance(acc3), after32)
        assertEqual(await user.getRecommenderBonusTimes(acc2), 6)
        //No longer transfer to the recommender after 100 times
        await user.setRecommenderBonusTimes(acc2, 100);
        const balance23 = web3.eth.getBalance(acc2)
        const balance33 = web3.eth.getBalance(acc3)
        await user.mockTransferAndCheckRecommender(acc2, amount, {from : acc1, value: 10000})
        const after23 = new BigNumber(balance23).plus(amount)
        assertEqual(web3.eth.getBalance(acc2), after23)
        assertEqual(web3.eth.getBalance(acc3), balance33)
        assertEqual(await user.getRecommenderBonusTimes(acc2), 101)

    })

})
