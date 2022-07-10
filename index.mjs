import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib();

const startingBalance = stdlib.parseCurrency(100);
const accAlice = await stdlib.newTestAccount(startingBalance);
const accMike = await stdlib.newTestAccount(startingBalance);

const fmt = (x) => stdlib.formatCurrency(startingBalance);

const ctcAlice = accAlice.contract(backend); // Alice is the deployer of the contract by calling the backend
const ctcMike = accMike.contract(backend, ctcAlice.getInfo());

const HAND = ['Rock', 'Paper', 'Scissors'];
const OUTCOME = ['Mike Wins', 'Draw', 'Alice wins'];
const Player = (Who) => ({
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
    }),
    ctcMike.p.Mike({
        // interact object here
        ...Player('Mike'),
    }),
]);