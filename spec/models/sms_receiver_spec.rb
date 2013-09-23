require 'spec_helper'

describe SmsReceiver, '#respond_to_sms!' do
  let(:inbound_message) { stub('InboundMessage', id: 111, keyword_response: 'stub response', actionable?: true) }
  let(:friendly_vendor) { stub_everything('I am a vendor. Call anything on me!',
                                          :'receive_message!' => inbound_message) }
  let(:keyword_bundle) { stub('KeywordBundle', 
                              keywords: [],
                              stop_text: 'you should stop now',
                              help_text: 'you have been helped',
                              stop_action: ->(*args) { friendly_vendor.stop!(*args)})}
  let(:command_parameters) { CommandParameters.new(:to => '+5554443334', :from => '+5554443333', :sms_body => 'subscribe foo@bar.com') }

  subject { SmsReceiver.new(friendly_vendor, command_parameters).tap{|s| s.bundle = keyword_bundle} }

  describe 'when dispatching on stop' do
    before do
      always_stop_parser = ->(body, dispatch) { dispatch['stop'].call }
      subject.parser = always_stop_parser
    end

    it 'calls #receive_message and #stop and returns stop_text' do
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :keyword_response => subject.stop_text).returns(inbound_message)
      friendly_vendor.expects(:stop!).with(command_parameters)
      subject.respond_to_sms!.should == 'stub response'
    end
  end

  describe 'when dispatching on help' do
    before do
      always_help_parser = ->(body, dispatch) { dispatch['help'].call }
      subject.parser = always_help_parser
    end

    it 'calls #receive_message and returns help_text' do
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :keyword_response => subject.help_text).returns(inbound_message)
      subject.respond_to_sms!.should == 'stub response'
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
      keyword_bundle.stubs(:keywords).returns([kw])

      subject.respond_to_sms!.should eq('stub response')
    end

    it "returns nil and does not call keyword's #execute_commands method if not actionable" do
      kw = stub('keyword')
      kw.stubs(:name).returns('kwname')
      kw.stubs(:response_text).returns('hee haw')
      kw.stubs(:account_id).returns(239423)
      command_parameters.expects(:sms_tokens=).with(['foo@bar.com'])
      # stuff that shouldn't happen
      command_parameters.expects(:inbound_message_id=).with(111).never
      kw.expects(:execute_commands).with(command_parameters).never
      keyword_bundle.stubs(:keywords).returns([kw])

      inbound_message.expects(:actionable?).returns(false)
      subject.respond_to_sms!.should eq(nil)
    end

    it 'returns nil for keyword dispatches when response_text is nil' do
      kw = mock(:name => 'kwname', :execute_commands => true)
      keyword_bundle.stubs(:keywords).returns([kw])
      inbound_message.expects(:keyword_response).returns(nil)
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :keyword => kw).returns(inbound_message)

      subject.respond_to_sms!.should be_nil
    end

    it 'calls receive_message!' do
      kw=mock(:name => 'kwname', :execute_commands => true)
      keyword_bundle.stubs(:keywords).returns([kw])
      friendly_vendor.expects(:receive_message!).with(:to => command_parameters.to, :from => command_parameters.from, :body => command_parameters.sms_body, :keyword => kw).returns(inbound_message)

      subject.respond_to_sms!
    end
  end
end
