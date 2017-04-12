import React from 'react'
import ReactDom from 'react-dom'
import { Provider } from 'react-redux'
import App from './components/app'
import { createStore } from 'redux'
import mailingsApp from './store/reducers/mailings'
import { fetchMailings } from './store/actions'
import { store, unsubscribe } from './store/store'

require('./styles/main.scss')

store.dispatch(fetchMailings());

ReactDom.render(
  <Provider store={store}>
    <App/>
  </Provider>,
  document.getElementById('app')
);

