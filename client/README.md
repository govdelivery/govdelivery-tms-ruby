XACT UI
=======

A React application that sits on top of the TMS UI and allows all manner of nice interactions to happen.

# Setup

1. Install node, npm, and yarn
2. Install dependencies: `yarn install`

## Running a server locally

_Temporary Hack_: copy `api_key.example.js` -> `api_key.js` and update it with your own TMS key from `rake helpers:api_key`

You can use the webpack dev server: `yarn server`

## Running tests 
We use mocha: `yarn test`
