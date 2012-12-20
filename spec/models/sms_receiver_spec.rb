require_relative '../../app/models/sms_receiver'
require_relative '../../app/models/action_parameters'
require_relative '../little_spec_helper'
require 'ostruct'

describe SmsReceiver, '#respond_to_sms!' do
  let(:friendly_vendor) { stub_everything('I am a vendor. Call anything on me!') }
  let(:action_parameters) { ActionParameters.new(:from => '+5554443333', :sms_body => 'subscribe foo@bar.com')}

  subject { SmsReceiver.new(friendly_vendor) }

  describe 'when dispatching on stop' do
    before do
      always_stop_parser = ->(body, dispatch){dispatch['stop'].call}
      subject.parser = always_stop_parser
    end

    it 'calls receive_message! with :stop? set to true' do
      friendly_vendor.expects(:receive_message!).with(:from => action_parameters.from, :body => action_parameters.sms_body, :stop? => true)

      subject.respond_to_sms!(action_parameters)
    end

    it 'returns stop_text' do
      subject.stop_text = 'you should stop now'
      subject.respond_to_sms!(action_parameters).should == 'you should stop now'
    end
  end

  describe 'when dispatching on help' do
    before do
      always_help_parser = ->(body, dispatch){dispatch['help'].call}
      subject.parser = always_help_parser
    end

    it 'calls receive_message! with :stop? set to false' do
      friendly_vendor.expects(:receive_message!).with(:from => action_parameters.from, :body => action_parameters.sms_body, :stop? => false)

      subject.respond_to_sms!(action_parameters)
    end

    it 'returns help_text' do
      subject.help_text = 'you have been helped'
      subject.respond_to_sms!(action_parameters).should == 'you have been helped'
    end
  end

  describe 'when dispatching on keywords' do
    before do
      always_kwname_parser = ->(body, dispatch){dispatch['kwname'].call('foo@bar.com')}
      subject.parser = always_kwname_parser
    end

    it "calls keyword's #execute_actions method" do
      kw = stub('keyword')
      kw.stubs(:name).returns('kwname')
      kw.stubs(:account_id).returns(239423)
      action_parameters.expects(:sms_tokens=).with(['foo@bar.com'])
      kw.expects(:execute_actions).with(action_parameters)
      subject.keywords = [kw]

      subject.respond_to_sms!(action_parameters)
    end

    it 'returns nil for keyword dispatches' do
      subject.keywords = [mock(:name => 'kwname', :execute_actions => 'returned by execute_actions')]

      subject.respond_to_sms!(action_parameters).should be_nil
    end

    it 'calls receive_message! with :stop? set to false' do
      friendly_vendor.expects(:receive_message!).with(:from => action_parameters.from, :body => action_parameters.sms_body, :stop? => false)

      subject.keywords = [mock(:name => 'kwname', :execute_actions => 'returned by execute_actions')]

      subject.respond_to_sms!(action_parameters)
    end
  end
end
