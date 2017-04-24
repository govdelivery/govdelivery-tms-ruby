// modules/settings.js
import React from 'react'
import { getHref } from '../actions/fetch_action_helper'

class Settings extends React.Component{
    render() {
        return (
            <div className="main-container" id="ie-main-contain">
                <div className="sr-card-api-callout sr-align-left">
                    <div className="sr-card-content">
                        <h3>
                            <i className="icon-life-bouy-api-callout medium"></i>
                                Get help with our API
                        </h3>
                        <p id='getting_started'>
                            View the <a id='getting_started_link' href="https://developer.govdelivery.com/api/tms/overview/Setup/">getting started guide</a> or <a id='api_docs_link' href="http://developer.govdelivery.com/api/tms/">visit our developer docs</a>
                        </p>
                    </div>
                </div>
                <h3>
                    Endpoint URL
                </h3>
                <p id='endpoint_url'>
              { getHref() }
                </p>
            </div>
        );
    }
}
Settings.displayName = 'Settings Page'

export default Settings
