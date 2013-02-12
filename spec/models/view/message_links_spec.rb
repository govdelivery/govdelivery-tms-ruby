require_relative '../../../app/models/view/message_links'
require_relative '../../little_spec_helper'
require 'ostruct'

describe View::MessageLinks do
  describe '#respond_to?' do
    subject { View::MessageLinks.new(stub(:foobar => :omg_lol), nil) }
    it 'works' do
      subject.foobar.should == :omg_lol
      subject.respond_to?(:foobar).should be_true
    end
  end

  describe '#_links in email context' do
    let(:context) {
      context = mock('Context')
      context.stubs(:controller_name).returns('email_messages')
      context
    }
    let(:message) {
      m = mock('EmailMessage')
      m.stubs(:id => 1)
      m
    }
    subject { View::MessageLinks.new(message, context) }
    it "should show email-specific links" do
      opts = {:only_path => true, :format => nil}
      message.stubs(:persisted?).returns(true)
      
      # recipients
      context.stubs(:url_for).with(opts.merge(:controller => 'recipients', :email_id => 1)).returns('recipients')

      # self
      context.stubs(:url_for).with(opts.merge(:controller => 'email_messages', :action => 'show', :id => 1)).returns('self')

      # opened
      context.expects(:url_for).with(opts.merge(:controller => 'recipients', :action => 'opened', :email_id => 1)).returns('opened')

      # clicked
      context.expects(:url_for).with(opts.merge(:controller => 'recipients', :action => 'clicked', :email_id => 1)).returns('clicked')

      subject._links.should == {:self => 'self', :recipients => 'recipients', :clicked => 'clicked', :opened => 'opened'}
    end
  end

  describe '#_links in sms context' do
    let(:context) {
      context = mock('Context')
      context.stubs(:controller_name).returns('sms_messages')
      opts = {:controller=>'recipients', :only_path => true, :format => nil}
      context.stubs(:url_for).with(any_of(opts.merge('sms_id' => 1), opts.merge(:sms_id => 1))).returns('bar')
      context
    }
    let(:message) {
      m = mock('SmsMessage')
      m.stubs(:id => 1)
      m
    }
    subject { View::MessageLinks.new(message, context) }
    it 'returns links for a persisted message' do
      opts = {:only_path => true, :format => nil}
      message.stubs(:persisted?).returns(true)
      context.stubs(:url_for).with(opts.merge(:controller => 'sms_messages', :action => 'show', :id => 1)).returns('foo')
      subject._links.should == {:self => 'foo', :recipients => 'bar'} 
    end
    it 'returns links for a new message' do
      opts = {:only_path => true, :format => nil}
      message.expects(:persisted?).returns(false)
      context.expects(:url_for).with(opts.merge(:controller => 'sms_messages')).returns('foo')
      subject._links.should == {:self => 'foo', :recipients => 'bar'}
    end
  end
end

