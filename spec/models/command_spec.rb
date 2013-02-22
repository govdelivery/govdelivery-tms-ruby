require 'spec_helper'

describe Command do
  subject {
    vendor = SmsVendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    account = create_account(sms_vendor: vendor)
    Command.new(:name => "FOO", :command_type => :dcm_unsubscribe, :params => CommandParameters.new(:dcm_account_codes => ["foo"])).tap{|c| c.account = account }
  }

  context "when valid" do
    specify { subject.valid?.should == true }
  end

  [:account, :command_type].each do |field|
    context "when #{field} is empty" do
      before { subject.send("#{field}=", nil) }
      specify { subject.valid?.should be_false }
    end
  end

  context "when name is too long" do
    before { subject.name = 'A'*256 }
    specify { subject.should be_invalid }
  end
  
  context "when params is too long" do
    before { subject.params = {'dcm_account_code' => 'A'*4001 } }
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

  context 'when command params are missing' do
    before do
      subject.command_type = :dcm_subscribe
      subject.params = {'dcm_topic_codes' => 'THIS, SHOULD BE AN ARRAY'}
    end
    it 'should show a proper error' do
      subject.valid?.should be_false
      subject.errors['params'].should eq(["has invalid #{subject.command_type} parameters: #{CommandType[subject.command_type].all_fields.map(&:to_s).join(', ')}"])
    end
  end

  context "call" do
    before do
      # Command should combine it's own (persisted) params with the incoming params, convert them to a 
      # hash, and pass them to the worker invocation
      expected = CommandParameters.new(:from => "+122222", :dcm_account_codes => ["foo"]).to_hash
      DcmUnsubscribeWorker.expects(:perform_async).with(expected)
    end
    specify { subject.call(CommandParameters.new(:from => "+122222")) }
  end
end