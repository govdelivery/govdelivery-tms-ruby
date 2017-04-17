import React from 'react'
import ReactDom from 'react-dom'
import { Provider } from 'react-redux'
import * as fetch from './actions/fetches'
import { store, history } from './store/store'
import { ConnectedRouter } from 'react-router-redux'

// Routing
import { Route } from 'react-router'
import App from './components/app'
import Settings from './components/settings'

store.dispatch(fetch.mailings())

require('../styles/main.scss')

ReactDom.render(
  <Provider store={store}>
    <ConnectedRouter history={history}>
      <div className="routes">
        <Route exact path="/" component={App}/>
        <Route path="/settings" component={Settings}/>
      </div>
    </ConnectedRouter>
  </Provider>,
  document.getElementById('app')
)
