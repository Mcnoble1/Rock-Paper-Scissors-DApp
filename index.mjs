import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

const startingBalance = stdlib.parseCurrency(100);
const accAlice = await stdlib.newTestAccount(startingBalance);
const accMike = await stdlib.newTestAccount(startingBalance);

const fmt = (x) => stdlib.formatCurrency(x, 4);
const getBalance = async (who) => fmt(await stdlib.balanceOf(who));
const beforeAlice = await getBalance(accAlice);
const beforeMike = await getBalance(accMike);

const ctcAlice = accAlice.contract(backend); // Alice is the deployer of the contract by calling the backend
const ctcMike = accMike.contract(backend, ctcAlice.getInfo());

const HAND = ['Rock', 'Paper', 'Scissors'];
const OUTCOME = ['Mike Wins', 'Draw', 'Alice wins'];
const Player = (Who) => ({
    ...stdlib.hasRandom,
    getHand: () => {
        const hand = Math.floor(Math.random() * 3);
        console.log(`${Who} played ${HAND[hand]}`);
        return hand; 
    },
    seeOutcome: (outcome) => {
        console.log(`${Who} saw outcome ${OUTCOME[outcome]}`);
        return null;
    },
});

await Promise.all([
    ctcAlice.p.Alice({
        // interact object here
        ...Player('Alice'),
        wager: stdlib.parseCurrency(5),
    }),
    ctcMike.p.Mike({
        // interact object here
        ...Player('Mike'),
        acceptWager: (amt) => {
            console.log(`Mike accepted wager of ${fmt(amt)}`);
            return null;
        }
        }
    ),
]);

const afterAlice = await getBalance(accAlice);
const afterMike = await getBalance(accMike);

console.log(`Alice went from ${beforeAlice} to ${afterAlice}`);
console.log(`Mike went from ${beforeMike} to ${afterMike}`);
