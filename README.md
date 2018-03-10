# Meetup Queueing System on a Block Chain
A queueing system on the blockchain for meetups

## Purpose

To allocate meetup spots in a fully transparent manner using smart contracts the ethereum blockchain


## Desgin questions
Each meetup event should be a separate contract?

## Verification

## Point Allocation
#### Earn points (non-event)
- Every account starts with 100 points 
- Work on group projects (discretionary, awarded by the meetup owners, maximum 1000 points per month) 
- Telegram contribution (sharing resources etc.) (discretionary, awarded by the meetup owners, maximum 1000 points per month) 

#### How to earn points (per event)
- Organise/assistantst: +30 
- Presenter: +100 
- Show up: +10 

#### How to lose points
- no show, no cancellation (or cancellation after event start time): -50
- late penalty:
more than 24 hours before the event: 0 
12 - 24 hours before the event: -2 
6 – 12 hours: -5 
3 – 6 hours: -10 
0 - 3 hours: -15 

## Queueing system
Based on total points
Waiting list also ranked by points, not by when you register

## Last minute auction system
Spots freed up in the last 3 hours are available for auctions
Auction the spots with your points


## Smart contract design

#### Variables
Meetup owner – multip owners, allow transfers
Meetup acconts - Array of addresses, mapped to meetup names

Meetup event
Organiser
Assistants
Presnenters
Date and time
Maximum capacity
Late cancellation period


####  Functions
Add account
Create a new meetup event – ownly owners can do this


