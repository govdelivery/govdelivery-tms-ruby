import { createStore } from 'redux'
import mailingsApp from './reducers/mailings'
import { fetchMailings } from './actions'


let store = createStore(mailingsApp);

console.log(store.getState())

// Every time the state changes, log it
// Note that subscribe() returns a function for unregistering the listener
let unsubscribe = store.subscribe(() =>
  console.log(store.getState())
)

store.dispatch(fetchMailings());
