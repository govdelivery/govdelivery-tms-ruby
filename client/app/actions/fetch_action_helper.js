import axios from 'axios'
import { key } from '../../api_key'

function getHref() {
  if (typeof location != 'undefined' && location.href.indexOf('localhost') > 0){
    return 'http://localhost:3000';
  } else if (typeof location == 'undefined') {
    return 'http://granicustest.com'
  }

  return '/';
}

const ROOT_URL = getHref()

export function fetch(route, type){
  return function(dispatch) {
    dispatch({type: type.FETCH})
    return axios({
      timeout: 20000,
      method: 'get',
      url: `${ROOT_URL}${route}`,
      headers: {
        'X-AUTH-TOKEN': key
      }
    })
    .then((response) => {
      dispatch({
        type: type.SUCCESS,
        payload: response.data
      })
    })
    .catch((error) => {
      dispatch({
        type: type.FAILURE,
        payload: error
      })
    })
  }
}
