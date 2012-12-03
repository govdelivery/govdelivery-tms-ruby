require 'spec_helper'

describe Account do
  subject {
    vendor = Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    Account.new(:name => 'name', :vendor => vendor)
  }

  it { should be_valid }
  
  context "when name is empty" do
    before { subject.name = nil }
    it { should_not be_valid }
  end
  
  context "when name too long" do
    before { subject.name = "W"*257 }
    it { should_not be_valid }
  end

  context "calling stop" do
    it 'should call actions' do
      subject.add_action!(:params => 'ACCOUNT_CODE', :action_type => Action::DCM_UNSUBSCRIBE)
      from = "123123123"
      Keyword.any_instance.expects(:execute_actions).never
      Action.any_instance.expects(:call).with(:from => from)
      subject.stop(:from => from)
    end
  end
end
