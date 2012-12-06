require_relative '../../app/models/sms_receiver'
require_relative '../little_spec_helper'
require 'ostruct'

describe SmsReceiver, '#respond_to_sms!' do
  let(:friendly_vendor) { stub_everything('I am a vendor. Call anything on me!') }
  let(:from) { '+5554443333' }
  let(:body) { 'a message body' }

  subject { SmsReceiver.new(friendly_vendor) }

  describe 'when dispatching on stop' do
    before do
      always_stop_parser = ->(body, dispatch){dispatch['stop'].call}
      subject.parser = always_stop_parser
    end

    it 'calls receive_message! with :stop? set to true' do
      friendly_vendor.expects(:receive_message!).with(:from => from, :body => body, :stop? => true)

      subject.respond_to_sms!(from, body)
    end

    it 'returns stop_text' do
      subject.stop_text = 'you should stop now'
      subject.respond_to_sms!(from, body).should == 'you should stop now'
    end
  end

  describe 'when dispatching on help' do
    before do
      always_help_parser = ->(body, dispatch){dispatch['help'].call}
      subject.parser = always_help_parser
    end

    it 'calls receive_message! with :stop? set to false' do
      friendly_vendor.expects(:receive_message!).with(:from => from, :body => body, :stop? => false)

      subject.respond_to_sms!(from, body)
    end

    it 'returns help_text' do
      subject.help_text = 'you have been helped'
      subject.respond_to_sms!(from, body).should == 'you have been helped'
    end
  end

  describe 'when dispatching on keywords' do
    before do
      always_kwname_parser = ->(body, dispatch){dispatch['kwname'].call}
      subject.parser = always_kwname_parser
    end

    it "calls keyword's #execute_actions method" do
      kw = stub('keyword')
      kw.stubs(:name).returns('kwname')
      kw.expects(:execute_actions).with(:from => from, :body => body)
      subject.keywords = [kw]

      subject.respond_to_sms!(from, body)
    end

    it 'returns nil for keyword dispatches' do
      subject.keywords = [mock(:name => 'kwname', :execute_actions => 'returned by execute_actions')]

      subject.respond_to_sms!(from, body).should be_nil
    end

    it 'calls receive_message! with :stop? set to false' do
      friendly_vendor.expects(:receive_message!).with(:from => from, :body => body, :stop? => false)

      subject.keywords = [mock(:name => 'kwname', :execute_actions => 'returned by execute_actions')]

      subject.respond_to_sms!(from, body)
    end
  end
end
