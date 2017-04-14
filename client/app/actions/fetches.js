import * as types from './action_types'
import { fetch } from './fetch_action_helper'

export function mailings(){
  return fetch('/messages/email/', types.MAILINGS)
}

export function fromAddresses() {
  return fetch('/from_addresses/', types.FROM_ADDRESSES)
}