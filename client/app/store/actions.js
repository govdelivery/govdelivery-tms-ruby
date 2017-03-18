import axios from 'axios';

const ROOT_URL = location.href.indexOf('localhost') > 0 ? 'http://localhost:3000' : '/'

export const FETCH_MAILINGS = 'FETCH_MAILINGS';
export const FETCH_MAILINGS_SUCCESS = 'FETCH_MAILINGS_SUCCESS';
export const FETCH_MAILINGS_FAILURE = 'FETCH_MAILINGS_FAILURE';

export const FETCH_MAILING  = 'FETCH_MAILING';
export const FETCH_MAILING_SUCCESS  = 'FETCH_MAILING_SUCCESS';
export const FETCH_MAILING_FAILURE  = 'FETCH_MAILING_FAILURE';

export function fetchMailings(){
 const request = axios({
    method: 'get',
    url: `${ROOT_URL}/messages/email/`,
    headers: ["X-AUTH-TOKEN:R2MMoeRmgnxGgUFsxPWmzScFPwEqYxmR"]
  });

  return {
    type: FETCH_MAILINGS,
    payload: request
  };
}

export function fetchMailingsSuccess(mailings) {
  return {
    type: FETCH_MAILINGS_SUCCESS,
    payload: mailings
  };
}

export function fetchMailingsFailure(error) {
  return {
    type: FETCH_MAILINGS_FAILURE,
    payload: error
  };
}

export function fetchMailing(id){
 const request = axios({
    method: 'get',
    url: `${ROOT_URL}/messages/email/${id}`,
    headers: ["X-AUTH-TOKEN:R2MMoeRmgnxGgUFsxPWmzScFPwEqYxmR"]
  });

  return {
    type: FETCH_MAILING,
    result: request
  }
}
