require 'spec_helper'

describe Command do
  subject {
    vendor = SmsVendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    account = create_account(sms_vendor: vendor)
    Command.new(:name => "FOO", :command_type => :dcm_unsubscribe, :params => CommandParameters.new(:url => "foo")).tap{|c| c.account = account }
  }

  context "when valid" do
    specify { subject.valid?.should == true }
  end

  [:account, :command_type].each do |field|
    context "when #{field} is empty" do
      before { subject.send("#{field}=", nil) }
      specify { subject.valid?.should == false }
    end
  end

  context "when name is too long" do
    before { subject.name = 'A'*256 }
    specify { subject.should be_invalid }
  end
  
  context "when params is too long" do
    before { subject.params = 'A'*4001 }
    specify { subject.should be_invalid }
  end

  context "when name is missing" do
    before { subject.name = nil; subject.save }
    specify { subject.name.to_s.should == subject.command_type.to_s }
  end

  context "when name is NOT missing" do
    before { subject.save }
    specify { subject.name.to_s.should_not == subject.command_type.to_s }
  end
  context "call" do
    before do
      # Command should combine it's own (persisted) params with the incoming params, convert them to a 
      # hash, and pass them to the worker invocation
      expected = CommandParameters.new(:from => "+122222", :url => "foo").to_hash
      DcmUnsubscribeWorker.expects(:perform_async).with(expected)
    end
    specify { subject.call(CommandParameters.new(:from => "+122222")) }
  end
end