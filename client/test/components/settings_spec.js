import chai, { expect } from 'chai'
import chaiEnzyme from 'chai-enzyme'
import { shallow } from 'enzyme'

import React from 'react'
import Setting from '../../app/components/settings'

chai.use(chaiEnzyme())

describe('Setting', () => {
  it('should initialize Settings', function() {
    const wrapper = shallow(<Setting/>)
    expect(wrapper.find('div.sr-card-api-callout > div > h3')).to.have.text('Get help with our API')
    expect(wrapper.find('div.sr-card-api-callout > div > h3 > i')).to.have.className('icon-life-bouy-api-callout')
    expect(wrapper.find('div.sr-card-api-callout > div > p > a#getting_started_link')).to.have.text('getting started guide')
    expect(wrapper.find('div.sr-card-api-callout > div > p > a#getting_started_link')).to.have.attr('href')
    expect(wrapper.find('div.sr-card-api-callout > div > p > a#api_docs_link')).to.have.text('visit our developer docs')
    expect(wrapper.find('div.sr-card-api-callout > div > p > a#api_docs_link')).to.have.attr('href')

    expect(wrapper.find('div.main-container > h3')).to.have.text('Endpoint URL')
  })

  it('should render an endpoint url based on current environment', function() {
    const wrapper = shallow(<Setting/>)
    expect(wrapper.find('p#endpoint_url')).to.have.text('http://granicustest.com')
  })
})
