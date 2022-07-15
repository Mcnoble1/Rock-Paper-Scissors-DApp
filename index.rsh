'reach 0.1';

const [ isHand, ROCK, PAPER, SCISSORS ] = makeEnum(3);
const [ isOutcome, M_WINS, DRAW, A_WINS ] = makeEnum(3);

const winner = (handAlice, handMike) => 
    ((handAlice + (4 - handMike)) % 3);

assert(winner(ROCK, PAPER) === M_WINS);
assert(winner(PAPER, ROCK) === A_WINS);
assert(winner(ROCK, ROCK) === DRAW);

forall(UInt, handAlice => {
    forall(UInt, handMike => {
        assert(isOutcome(winner(handAlice, handMike)));
    })
});

forall(UInt, (hand) => {
    assert(winner(hand, hand) === DRAW);
})

// Participant Interact interface
const Player = {
    ...hasRandom,
    getHand: Fun([], UInt),
    seeOutcome: Fun([UInt], Null),
};

//  App initialization: definition of Players
export const main = Reach.App(() => {
    const Alice = Participant('Alice', {
        // interact interface here
        ...Player,
        wager: UInt,
    });
    const Mike = Participant('Mike', {
        // interact interface here
        ...Player,
        acceptWager: Fun([UInt], Null),
    });
    init();
 
    Alice.only(() => {
        const wager = declassify(interact.wager);
        const _handAlice = interact.getHand();
        const [ _commitAlice, _saltAlice] = makeCommitment(interact, _handAlice);
        const commitAlice = declassify(_commitAlice);
    });
    Alice.publish(wager, commitAlice) // publish wager and commitment
        .pay(wager);
    commit();

    unknowable(Mike, Alice(_handAlice, _saltAlice)); // Mike can't see Alice's hand

    Mike.only(() => {
        interact.acceptWager(wager);
        const handMike = declassify(interact.getHand());
        // const handMike = (handAlice + 1) % 3;

    });     
    Mike.publish(handMike)
        .pay(wager);
    commit();

    Alice.only(() => {
        const saltAlice = declassify(_saltAlice);
        const handAlice = declassify(_handAlice);
    });
    Alice.publish(saltAlice, handAlice)
    checkCommitment(commitAlice, saltAlice, handAlice);

    const outcome = (handAlice + (4 - handMike)) % 3;
    const               [forAlice, forMike] = 
        outcome == 2 ?  [       2,      0] :
        outcome == 0 ?  [       0,      2] :
        /* tie      */  [       1,      1];
    transfer(forAlice * wager).to(Alice);
    transfer(forMike * wager).to(Mike);
    commit();

    each([Alice, Mike], () => {
        interact.seeOutcome(outcome);
    });
});