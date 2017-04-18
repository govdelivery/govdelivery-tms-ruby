import mailings from '../reducers/mailings'
import { createStore, applyMiddleware, compose, combineReducers } from 'redux'
import thunk from 'redux-thunk'
import { routerReducer, routerMiddleware } from 'react-router-redux'
import createHistory from 'history/createBrowserHistory'

export const history = createHistory()

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose

const middleware = routerMiddleware(history)

let store = createStore(
  combineReducers({
    mailings,
    routing: routerReducer
  }),
  composeEnhancers(
    applyMiddleware(thunk),
    applyMiddleware(middleware)
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