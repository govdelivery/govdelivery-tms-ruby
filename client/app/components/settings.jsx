// modules/settings.js
import React from 'react'

class Settings extends React.Component{
  render() {
    return (
      <div>
        <div>
          <div className="sr-align-left sr-card-api-callout">
            <i className="icon-life_bouy-float-right huge"></i>
            <h3 id='get_help'>
              Get help with our API
            </h3>
            <p id='getting_started'>
              View the <a id='getting_started_link' href="www.google.com">getting started guide</a> or <a id='api_docs_link' href="http://developer.govdelivery.com/api/tms/">visit our developer docs</a>
            </p>
          </div>
        </div>
        <div className="sr-card-warning">
          <div className="sr-card-content">
            <h3>
              Endpoint URL
            </h3>

            <p>
              tms.govdelivery.com
            </p>
          </div>
        </div>
      </div>
    );
  }
}
Settings.displayName = 'Settings Page'

export default Settings
