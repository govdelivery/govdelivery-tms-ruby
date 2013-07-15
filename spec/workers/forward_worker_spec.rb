require File.expand_path("../../little_spec_helper", __FILE__)
require 'spec_helper'

describe ForwardWorker do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:options) { {:url => "url",
                   :http_method => "post",
                   :username => nil,
                   :password => nil,
                   :from => "333",
                   :sms_body => "sms body",
                   :account_id => account.id,
                   :command_id => 11,
                   :callback_url => "http://localhost"} }

  let(:message) { stub('SmsMessage') }
  let(:forward_response) { stub(status: 200, body: "ATLANTA IS FULL OF ZOMBIES, STAY AWAY") }
  let(:invalid_response) { stub(status: 0, env: {url: 'http://whaaaat'}) }
  let(:command) { stub('Command') }

  subject do
    fw = ForwardWorker.new
    fw.http_service = mock('forward_service')
    fw.sms_service=mock('sms_service')
    fw
  end

  it 'should perform happily' do
    subject.stubs(:command).returns(command)
    subject.http_service.expects(:post).with("url", nil, nil, {:from => "333", :sms_body => "sms body"}).returns(forward_response)
    command.expects(:process_response).with(instance_of(Account), instance_of(CommandParameters), forward_response).returns(message)
    subject.sms_service.expects(:deliver!).with(message, options[:callback_url])

    subject.perform(options)
  end

  it 'should not send a message if there isn\'t one' do
    subject.stubs(:command).returns(command)
    subject.http_service.expects(:post).with("url", nil, nil, {:from => "333", :sms_body => "sms body"}).returns(forward_response)
    command.expects(:process_response).with(instance_of(Account), instance_of(CommandParameters), forward_response).returns(nil)
    subject.sms_service.expects(:deliver!).never

    subject.perform(options)
  end

  it 'should record a failure if we get a response without a status' do
    subject.stubs(:command).returns(command)
    subject.http_service.expects(:post).with("url", nil, nil, {:from => "333", :sms_body => "sms body"}).returns(invalid_response)
    command.expects(:process_response).with(instance_of(Account), instance_of(CommandParameters), instance_of(OpenStruct)).returns(nil)
    subject.sms_service.expects(:deliver!).never

    subject.perform(options)
    subject.exception.should_not be_nil
  end
end
