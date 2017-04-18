XACT UI
=======

A React application that sits on top of the TMS UI and allows all manner of nice interactions to happen.

# Setup

1. Install node and npm: Use nodenv (on a mac, that's `brew install nodenv; nodenv init`)
2. Install yarn: `brew install yarn`
3. Install dependencies: `yarn install`

## Optional
- Install the [React Chrome Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi)
- Install the [Redux Chrome Developer Tools](https://github.com/zalmoxisus/redux-devtools-extension)

## Running a server locally

_Temporary Hack_: copy `api_key.example.js` -> `api_key.js` and update it with your own TMS key from `rake helpers:api_key`

You can use the webpack dev server: `yarn server`

## Running tests 
We use mocha: `yarn test`
