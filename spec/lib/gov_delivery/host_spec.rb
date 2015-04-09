require 'spec_helper'
require File.join(File.expand_path('../../../../lib', __FILE__), 'gov_delivery', 'host')

describe GovDelivery::Host do
  it 'should parse stuff correctly in dev' do
    host = GovDelivery::Host.new
    host.expects(:hostname).returns('officedc4.office.gdi')
    expect(host.env).to eq('officedc4')
    expect(host.datacenter).to eq('office')
  end

  it 'should parse stuff correctly in ep' do
    host = GovDelivery::Host.new
    host.expects(:hostname).returns('qc-xactbg1.ep.gdi')
    expect(host.env).to eq('qc')
    expect(host.datacenter).to eq('ep')
  end
end
