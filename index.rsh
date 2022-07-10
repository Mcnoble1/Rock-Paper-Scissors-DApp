'reach 0.1'

// Participant Interact interface
const Player = {
    getHand: Fun([], UInt),
    seeOutcome: Fun([UInt], Null),
};

//  App initialization: definition of Players
export const main = Reach.App(() => {
    const Alice = Participant('Alice', {
        // interact interface here
        ...Player,
    });
    const Mike = Participant('Mike', {
        // interact interface here
        ...Player,
    });
    init();

    Alice.only(() => {
        const handAlice = declassify(interact.getHand());
    });
    Alice.publish(handAlice);
    commit();
    Mike.only(() => {
        const handMike = declassify(interact.getHand());
    });     
    Mike.publish(handMike);

    const outcome = (handAlice + (4 - handMike)) % 3;
    commit();

    each([Alice, Mike], () => {
        interact.seeOutcome(outcome);
    });
});