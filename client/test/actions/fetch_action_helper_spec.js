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

  it('should handle successful get', function() {
    const store = mockStore({ })

    nock('http://localhost:3000/')
      .get('/dummy_endpoint')
      .reply(200, { body: { stuff: 'hi' }})

    return store.dispatch(actions.fetch('/dummy_endpoint', types.MAILINGS))
      .then(() => {
        expect(store.getActions()[0]['type']).toEqual(types.MAILINGS.FETCH)
        expect(store.getActions()[1]['type']).toEqual(types.MAILINGS.SUCCESS)
        expect(store.getActions()[1]['payload']).toEqual({ body: { stuff: 'hi' }})
      })
  })

  it('should handle unsuccessful get', function() {
    const store = mockStore({ })

    nock('http://localhost:3000/')
      .get('/dummy_endpoint')
      .replyWithError( {'message':'Unauthorized','status_code':'401'})

    return store.dispatch(actions.fetch('/dummy_endpoint', types.MAILINGS))
      .then(() => {
        expect(store.getActions()[0]['type']).toEqual(types.MAILINGS.FETCH)
        expect(store.getActions()[1]['type']).toEqual(types.MAILINGS.FAILURE)
        expect(store.getActions()[1]['payload']['message']).toEqual('Unauthorized')
        expect(store.getActions()[1]['payload']['status_code']).toEqual('401')
      })
  })
})