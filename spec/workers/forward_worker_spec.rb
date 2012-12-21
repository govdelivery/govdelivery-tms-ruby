require File.expand_path("../../little_spec_helper", __FILE__)
require 'spec_helper'

describe ForwardWorker do
  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:options) { {:url => "url", :method => "post", :username => nil, :password => nil, :from => "333", :sms_body => "sms body", :account_id => account.id} }
  subject { ForwardWorker.new }

  it 'should perform happily' do
    forward_response = mock(:body => "ATLANTA IS FULL OF ZOMBIES, STAY AWAY")
    subject.forward_service = mock
    subject.forward_service.expects(:post).with("url", nil, nil, {:from => "333", :sms_body => "sms body"}).returns(forward_response)
    
    subject.perform(options)
  end
end
