import { createStore } from 'redux'
import mailingsApp from './reducers/mailings'
import { fetchMailings } from './actions'


let store = createStore(
  mailingsApp,
   window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__()
);

// Every time the state changes, log it
// Note that subscribe() returns a function for unregistering the listener
let unsubscribe = store.subscribe(() =>
  console.log(store.getState())
)

export {
  store,
  unsubscribe
}