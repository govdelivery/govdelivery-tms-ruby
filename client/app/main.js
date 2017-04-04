import React from 'react'
import ReactDom from 'react-dom'
import { Provider } from 'react-redux'
import App from './components/app'
import { createStore } from 'redux'
import mailingsApp from './store/reducers/mailings'
import { fetchMailings } from './store/actions'

require('./styles/main.scss')

let store = createStore(mailingsApp);

ReactDom.render(
  <Provider store={store}>
    <App/>
  </Provider>,
  document.getElementById('app')
);

