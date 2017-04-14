import React from 'react'
import ReactDom from 'react-dom'
import { Provider } from 'react-redux'
import App from './components/app'
import * as fetch from './actions/fetches'
import { store } from './store/store'

store.dispatch(fetch.mailings())

require('../styles/main.scss')

ReactDom.render(
  <Provider store={store}>
    <App/>
  </Provider>,
  document.getElementById('app')
)
