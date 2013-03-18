require 'spec_helper'

describe SmsReceiver, '#respond_to_sms!' do
  let(:inbound_message) { stub('InboundMessage', id: 111) }
  let(:friendly_vendor) { stub_everything('I am a vendor. Call anything on me!', :'receive_message!' => inbound_message) }
  let(:command_parameters) { CommandParameters.new(:to => '+5554443334', :from => '+5554443333', :sms_body => 'subscribe foo@bar.com') }

  subject { SmsReceiver.new(friendly_vendor) }

  describe 'when dispatching on stop' do
    before do
      always_stop_parser = ->(body, dispatch) { dispatch['stop'].call }
      subject.parser = always_stop_parser
    end

    it 'calls receive_message! with :stop? set to true' do
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :stop? => true, :keyword_response => nil).returns(inbound_message)

      subject.respond_to_sms!(command_parameters)
    end

    it 'returns stop_text' do
      subject.stop_text = 'you should stop now'
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :stop? => true, :keyword_response => subject.stop_text).returns(inbound_message)
      subject.respond_to_sms!(command_parameters).should == 'you should stop now'
    end
  end

  describe 'when dispatching on help' do
    before do
      always_help_parser = ->(body, dispatch) { dispatch['help'].call }
      subject.parser = always_help_parser
    end

    it 'calls receive_message! with :stop? set to false' do
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :stop? => false, :keyword_response => nil).returns(inbound_message)
      subject.respond_to_sms!(command_parameters)
    end

    it 'returns help_text' do
      subject.help_text = 'you have been helped'
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :stop? => false, :keyword_response => subject.help_text).returns(inbound_message)
      subject.respond_to_sms!(command_parameters).should == 'you have been helped'
    end
  end

  describe 'when dispatching on keywords' do
    before do
      always_kwname_parser = ->(body, dispatch) { dispatch['kwname'].call('foo@bar.com') }
      subject.parser = always_kwname_parser
    end

    it "calls keyword's #execute_commands method" do
      kw = stub('keyword')
      kw.stubs(:name).returns('kwname')
      kw.stubs(:response_text).returns('hee haw')
      kw.stubs(:account_id).returns(239423)
      command_parameters.expects(:sms_tokens=).with(['foo@bar.com'])
      command_parameters.expects(:inbound_message_id=).with(111)
      kw.expects(:execute_commands).with(command_parameters)
      subject.keywords = [kw]

      subject.respond_to_sms!(command_parameters).should eq('hee haw')
    end

    it 'returns nil for keyword dispatches when response_text is nil' do
      subject.keywords = [mock(:name => 'kwname', :execute_commands => 'returned by execute_commands', :response_text => nil)]

      subject.respond_to_sms!(command_parameters).should be_nil
    end

    it 'calls receive_message! with :stop? set to false' do
      kw=mock(:name => 'kwname', :execute_commands => 'returned by execute_commands', :response_text => nil)
      subject.keywords = [kw]
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :stop? => false, :keyword => kw).returns(inbound_message)

      subject.respond_to_sms!(command_parameters)
    end
  end
end
