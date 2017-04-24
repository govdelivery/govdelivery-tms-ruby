// modules/settings.js
import React from 'react'
import { getHref } from '../actions/fetch_action_helper'

class Settings extends React.Component{
  render() {
    return (
      <div>
        <div className="sr-card-api-callout sr-align-left">
          <div className="sr-card-content">
            <i className="icon-life-bouy-api-callout large"></i>
            <h3>Get help with our API</h3>
            <p id='getting_started'>
              View the <a id='getting_started_link' href="https://developer.govdelivery.com/api/tms/overview/Setup/">getting started guide</a> or <a id='api_docs_link' href="http://developer.govdelivery.com/api/tms/">visit our developer docs</a>
            </p>
          </div>
        </div>
        <div className="sr-card">
          <div className="sr-card-content">
            <h3>
              Endpoint URL
            </h3>
            <p id='endpoint_url'>
              { getHref() }
            </p>
          </div>
        </div>
      </div>
    );
  }
}
Settings.displayName = 'Settings Page'

export default Settings
