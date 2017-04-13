import * as types from './action_types'
import { fetch } from './fetch_action_helper'

export function fetchMailings(){
  return fetch('/messages/email/', types.FETCH_MAILINGS, types.FETCH_MAILINGS_SUCCESS, types.FETCH_MAILINGS_FAILURE)
}

