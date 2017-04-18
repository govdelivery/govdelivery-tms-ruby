import chai, { expect } from 'chai'
import chaiEnzyme from 'chai-enzyme'
import { shallow } from 'enzyme'

import React from 'react'
import Mailing from '../../app/components/mailing'

chai.use(chaiEnzyme())

describe('Mailing', () => {
  it('should initialize Mailing with default props', function() {
    const wrapper = shallow(<Mailing/>)
    expect(wrapper.find('h3')).to.have.text('No emails yet')
  })
})
