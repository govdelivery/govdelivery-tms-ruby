import chai, { expect } from 'chai'
import chaiEnzyme from 'chai-enzyme'
import { shallow } from 'enzyme'

import React from 'react'
import Setting from '../../app/components/settings'

chai.use(chaiEnzyme())

describe('Setting', () => {
  it('should initialize Settings', function() {
    const wrapper = shallow(<Setting/>)
    expect(wrapper.find('div')).to.have.text('settings')
  })
})
