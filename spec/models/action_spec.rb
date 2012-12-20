require 'spec_helper'

describe Action do
  subject {
    vendor = Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    account = create_account(vendor: vendor)
    Action.new(:account => account, :name => "FOO", :action_type => Action::DCM_UNSUBSCRIBE, :params => "PARAMETER OMG")
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
      expected = ActionParameters.new(:params => "PARAMETER OMG", :from => "+122222").to_hash
      DcmUnsubscribeWorker.expects(:perform_async).with(expected)
    end
    specify { subject.call(ActionParameters.new(:from => "+122222")) }
  end
end
