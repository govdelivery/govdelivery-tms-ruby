require 'spec_helper'

describe Action do
  subject {
    vendor = Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    account = create_account(vendor: vendor)
    Action.new(:account => account, :name => "FOO", :action_type => :dcm_unsubscribe, :params => ActionParameters.new(:url => "foo"))
  }

  context "when valid" do
    specify { subject.valid?.should == true }
  end

  [:account, :action_type].each do |field|
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

  context "call" do
    before do
      # Action should combine it's own (persisted) params with the incoming params, convert them to a 
      # hash, and pass them to the worker invocation
      expected = ActionParameters.new(:from => "+122222", :url => "foo").to_hash
      DcmUnsubscribeWorker.expects(:perform_async).with(expected)
    end
    specify { subject.call(ActionParameters.new(:from => "+122222")) }
  end
end
