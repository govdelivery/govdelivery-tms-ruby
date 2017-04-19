import reducer from '../../app/reducers/mailings'
import * as types from '../../app/actions/action_types'
import expect from 'expect'

describe('mailings reducer', () => {
  it('should return the initial state with no action', () => {
    expect(
      reducer(undefined, {})
    ).toEqual(
      {
        list: []
      }
    )
  })

  it('should return a new state with mailings success', () => {
    expect(
      reducer(undefined, { type: types.MAILINGS.SUCCESS, payload: { body: 'stuff' }})
    ).toEqual(
      {
        list: { body: 'stuff' }
      }
    )
  })
})
