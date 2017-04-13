import mailingsApp from '../reducers/mailings'
import { createStore, applyMiddleware, compose } from 'redux'
import thunk from 'redux-thunk'


const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose

let store = createStore(
  mailingsApp,
  composeEnhancers(
    applyMiddleware(thunk)
  )
)

/* eslint-disable no-console */
let unsubscribe = store.subscribe(() =>
  console.log(store.getState())
)
/* eslint-enable */

export {
  store,
  unsubscribe
}