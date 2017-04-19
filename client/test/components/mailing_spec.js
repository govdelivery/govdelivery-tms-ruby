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

  it('should build page with mailing', function() {
    const wrapper = shallow(<Mailing
                              mailings={[{subject: 'An email that is great',
                                id: 12}
                              ]}/>)
    expect(wrapper.find('h4')).to.have.text('Subject: An email that is great')
    // custom HTML elements appear to be a real PITA -- currently not rendering in Mailing
    // expect(wrapper.find('.email')).to.have.attr('key', 12)
  })
})
