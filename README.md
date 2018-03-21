# Meetup Queueing System on a Blockchain

A queueing system on the blockchain for meetups

---

# Table of Contents
  * [About](#chapter-0)
  * [Setup Instructions](#chapter-10)

# About <a id="chapter-0"></a>

## Discussion Questions

MVP: just build the meetup mechanism to start with

## Purpose

To allocate meetup spots in a fully transparent manner using smart contracts the ethereum blockchain 

Reward people for regular attendance and contribution 

Penalise people for late cancellation and no show's

Most importantly, use this project as an opportunity to learn to write a diverse range of smart contracts

## Background

[BokkyPooBahs-Ethereum-Workshop](https://www.meetup.com/BokkyPooBahs-Ethereum-Workshop/) has become so popular that the available spots often get fully booked out within a few minutes. Since the meetup is about blockchain, why not solving this problem using blockchain?


## Features
- [x] Basic solidity contract
- [ ] Authenticate users before each event
- [ ] Reward/ deduct points
- [ ] Last minute auction
- [ ] Insurance pool for points penalty
- [ ] Borrowing/lending points
- [ ] Reward points for projects - allow users to submit a github repo
- [ ] Monthly community voting - to decide which gitub repo to award points to
- [ ] Distribute award points based on number of commits
- [ ] Replace points with an ERC20 token (which can only be earned, but not bought)
- [ ] Web frontend
- [ ] App

## Reasons for using the Ropsten network 

- No transaction cost (ETH can be obtained for free)
- Low latency if putting a high enough gas price (low latency is important for event entrance and time dependent late cancellations) 


## Verification

#### Initial registration

We need to move the meetup account database or a form of identity based on it onto the blockchain.

**Steps**

- Create a master list of meetup account ID's based on the meetup website  
- Users need to set up a new Ethereum account and get free Ropsten ETH (details to be followed)  
- Users go to the website and register using their meetup account name  
- Users can also deregister them selves in case of mistakes  
- Contract owners can deregister users (e.g. when someone accidentally registers another user's account)  

#### Register for individual meetup events

Accounts are checked against the masterlist

#### Verification at the door

- There'll be a smart phone app that users can store their Ethereum public address and present it as QR codes 
- Before each meetup, the organisers will need to use an app to scan users QR codes 
- Only registered people are allowed to enter 

## Point incentives
#### Earn points (non-event)
- Every account starts with 100 points 
- Work on group projects (discretionary, awarded by the meetup owners, maximum 1000 points per month) 
- Telegram contribution (sharing resources etc.) (discretionary, awarded by the meetup owners, maximum 1000 points per month) 

#### Earn points (per event)
- Organise/assistantst: +30 
- Presenter: +100 
- Show up: +10 

#### How to lose points
- To participate in events, need to put in a deposit of 50 points
- no show, no cancellation (or cancellation after event start time): -50
- late penalty:
  - more than 24 hours before the event: 0 
  - 12 - 24 hours before the event: -2 
  - 6 – 12 hours: -5 
  - 3 – 6 hours: -10 
  - 0 - 3 hours: -15 

## Queueing system
- Based on total points 
- Waiting list also ranked by points, not by when you register
- Use registration order for tie-breakers

## Last minute auction system (replacing the waiting list)
- Spots freed up in the last 3 hours are available for auctions 
- Auction the spots with your points
- Auction starts when at least one spot opens up
- Auction ends 1 hour before the meetup

## Smart contract design

### Contract 1 - meetup base, inherits access control

#### Variables
- Meetup owner – multip owners, allow transfers 
- Meetup acconts - Array of addresses, mapped to meetup names 
- Array of meetup events (contract addresses) 

**Meetup event (struct)** 

- Organiser 
- Assistants 
- Presnenters 
- Date and time 
- Maximum capacity 
- Late cancellation period

####  Functions

- Register user
- Deregister user
- Create a new meetup event – ownly organiser and assistants can do this
- Cancel a meetup event – ownly organiser and assistants can do this
- Register for a meetup event
- Deregister from a meetup event
- Enter into last minute auction



## Boilderplate
http://truffleframework.com/boxes/react-uport


# Setup Instructions <a id="chapter-10"></a>

## Prerequisites

* Install Node.js 9.x.x with [NVM](https://github.com/creationix/nvm)

## Development - Installation and Building

### Alternative 1

* Install Truffle, Ganache CLI ethereum client for local development, and Yarn

```bash
npm install -g truffle ganache-cli;
brew install yarn
```

* Change into the project directory

```bash
cd react-uport/
```

* Install the node dependencies.

```bash
yarn install
```

* Run Ganache CLI.

```bash
ganache-cli \
  --port="7545" \
  --mnemonic "obey flight jump bean salt female logic inside sugar case venture media" \
  --verbose \
  --networkId=1000 \
  --gasLimit=7984452 \
  --gasPrice=2000000000;
```

* Compile and migrate the contracts.

```bash
truffle compile;
truffle migrate --network development
```

* Run Webpack server for front-end hot reloading
    * Note: Smart contract changes must be manually recompiled and migrated.

```bash
yarn start
```

* Debug (use Truffle Console after starting Ganache CLI in a separate tab)

```
truffle console
truffle(development)> for (var i in web3.eth.accounts) { console.log(web3.eth.getBalance(web3.eth.accounts[i])) }
```

### Alternative 2

Go to [ganache github](https://github.com/trufflesuite/ganache/releases) and install v1.1.0-beta.1 - Candy Apple

Note: the latest stable release crashes frequently and does not give consistent results


## Testing

#### React Components

* Jest used to test React components using Truffle

```bash
truffle compile;
truffle migrate --network development;
yarn test
```

#### Smart Contracts

Truffle used to test Smart Contracts

```bash
truffle compile;
truffle migrate --network development;
truffle test
```

## Production

```bash
yarn build
```
