import * as types from '../actions/action_types'

const initialState = {
  list: []
}

function mailingsApp(state = initialState, action){
  switch(action.type){
    case types.MAILINGS.SUCCESS:
      return Object.assign({}, state, {
        list: action.payload
      })
    default:
      return state
  }
}

export default mailingsApp
