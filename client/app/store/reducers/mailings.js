import { FETCH_MAILINGS } from '../actions'

const initialState = {
  mailings: []
}

function mailingsApp(state = initialState, action){
  switch(action.type){
    case FETCH_MAILINGS:
      return Object.assign({}, state, {
        mailings: action.payload
      })
    default:
      return state;
  }

  return state;
}

export default mailingsApp;
