import React from 'react'
import ReactDom from 'react-dom'
import { Provider } from 'react-redux'
import App from './components/app'
import { fetchMailings } from './actions/actions'
import { store } from './store/store'

store.dispatch(fetchMailings())

ReactDom.render(
  <Provider store={store}>
    <App/>
  </Provider>,
  document.getElementById('app')
)
