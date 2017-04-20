// modules/settings.js
import React from 'react'

const api_callout =
<div>
  <div>
    <div className="sr-align-left sr-card-api-callout">
      <i className="icon-life_bouy-float-right huge"></i>
      <h3>
        Get help with our API
      </h3>
      <p>
        View the <a href="www.google.com">getting started guide</a> or <a href="http://developer.govdelivery.com/api/tms/">visit our developer docs</a>
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
</div>;

class Settings extends React.Component{
  render() {
    return api_callout
  }
}
Settings.displayName = 'Settings Page'

export default Settings
