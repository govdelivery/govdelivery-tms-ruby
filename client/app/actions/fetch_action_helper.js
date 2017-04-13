import axios from 'axios'
const ROOT_URL = location.href.indexOf('localhost') > 0 ? 'http://localhost:3000' : '/'

export function fetch(route, type, success, failure){
  return function(dispatch) {
    dispatch({type: type})
    return axios({
      timeout: 20000,
      method: 'get',
      url: `${ROOT_URL}${route}`,
      headers: {
        'X-AUTH-TOKEN': 'MU7yPSDMTU9Lv7ppY6zSJH1gyY5rwHUi'
      }
    })
    .then((response) => {
      dispatch({
        type: success,
        payload: response.data
      })
    })
    .catch((error) => {
      dispatch({
        type: failure,
        payload: error
      })
    })
  }
}
