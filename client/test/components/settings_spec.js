import chai, { expect } from 'chai'
import chaiEnzyme from 'chai-enzyme'
import { shallow } from 'enzyme'

import React from 'react'
import Setting from '../../app/components/settings'

chai.use(chaiEnzyme())

describe('Setting', () => {
  it('should initialize Settings', function() {
    const wrapper = shallow(<Setting/>)
    expect(wrapper.find('div.sr-align-left > h3')).to.have.text('Get help with our API')
    expect(wrapper.find('div.sr-align-left > i')).to.have.className('icon-life_bouy-float-right')
    expect(wrapper.find('div.sr-align-left > p > a#getting_started_link')).to.have.text('getting started guide')
    expect(wrapper.find('div.sr-align-left > p > a#getting_started_link')).to.have.attr('href')
    expect(wrapper.find('div.sr-align-left > p > a#api_docs_link')).to.have.text('visit our developer docs')
    expect(wrapper.find('div.sr-align-left > p > a#api_docs_link')).to.have.attr('href')

    expect(wrapper.find('div.sr-card-content > h3')).to.have.text('Endpoint URL')
  })

  it('should render an endpoint url based on current environment', function() {
    // todo
  })
})
