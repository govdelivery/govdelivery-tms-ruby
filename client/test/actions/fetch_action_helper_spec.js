// see http://redux.js.org/docs/recipes/WritingTests.html

import configureMockStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import * as actions from '../../app/actions/fetch_action_helper'
import * as types from '../../app/actions/action_types'
import nock from 'nock'
import expect from 'expect'

const middlewares = [ thunk ]
const mockStore = configureMockStore(middlewares)

// need location.href for ROOT_URL

describe('fetch_action_helper', () => {
  afterEach(() => {
    nock.cleanAll()
  })

  // it('should handle successful get', function() {
  //   const store = mockStore({ })

  //   return store.dispatch(actions.fetch('dummy_endpoint', types.MAILINGS))
  //     .then(() => { // return of async actions
  //       expect(store.getActions()).toEqual('')
  //     })
  // })

  it('should handle unsuccessful get', function() {
    // nock('http://example.com/')
    //   .get('/todos')
    //   .reply(200, { body: { todos: ['do something'] }})

    const store = mockStore({ })

    return store.dispatch(actions.fetch('dummy_endpoint', types.MAILINGS))
      .then(() => { // return of async actions
        expect(store.getActions()[0]['type']).toEqual(types.MAILINGS.FETCH)
        expect(store.getActions()[1]['type']).toEqual(types.MAILINGS.FAILURE)
      })
  })
})