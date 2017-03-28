import chai, { expect } from 'chai'
import chaiEnzyme from 'chai-enzyme'
import { shallow } from 'enzyme'

import React from 'react'
import Mailing from '../../app/components/mailing'

chai.use(chaiEnzyme())

describe('Mailing', function(){

  it('should initialize Mailing with default props', function() {
    const wrapper = shallow(<Mailing/>)
    expect(wrapper).to.have.className('mailing')
    expect(wrapper.find('h1')).to.have.text('Hello, world!')
  })
})
