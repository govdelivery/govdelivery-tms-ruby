require 'spec_helper'

describe ForwardWorker do
  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  
  subject { ForwardWorker.new }

  it 'should perform happily' do
    forward_response = "ATLANTA IS FULL OF ZOMBIES, STAY AWAY"
    subject.forward_service = mock
    subject.forward_service.expects(:post).with("url", {:from => "+12223334444", :sms_body => "SERVICES 33333"}).returns(forward_response)
    # subject.twilio_service = mock
    # subject.twilio_service.expects(:send).with(:from => "+12223334444", :sms_body => forward_response)

    subject.perform(:params => "POST url", :from => "+12223334444", :sms_body => "SERVICES 33333")
  end
end
