import { FETCH_MAILINGS } from '../actions'

const initialState = {
  mailings: [
    {
      key: 15557230,
      from_email: "notices@healthcare.gov",
      subject: "Welcome! Please verify your email for your HealthCare.gov account."
    }
  ]
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
