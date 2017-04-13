import * as types from '../actions/action_types'

const initialState = {
  mailings: []
}

function mailingsApp(state = initialState, action){
  switch(action.type){
    case types.FETCH_MAILINGS_SUCCESS:
      return Object.assign({}, state, {
        mailings: action.payload
      })
    default:
      return state
  }
}

export default mailingsApp
