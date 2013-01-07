require 'spec_helper'

describe Account do
  subject {
    vendor = Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    Account.new(:name => 'name', :vendors => [vendor])
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
      subject.add_action!(:params => ActionParameters.new(:dcm_account_codes => ['ACCOUNT_CODE']), :action_type => Action::DCM_UNSUBSCRIBE)
      from = "123123123"
      Keyword.any_instance.expects(:execute_actions).never
      Action.any_instance.expects(:call).with(:from => from)
      subject.stop(:from => from)
    end
  end
  
  context 'with multiple vendors' do
    before do
    subject.vendors << Vendor.create!(:name => 'new name', :username => 'username2', :password => 'secret2', :from => 'from', :worker => 'TwilioVoiceWorker')
    end
    specify { subject.voice_vendor.name.should == 'new name' }
    specify { subject.sms_vendor.name.should == 'name' }
    it{should be_valid}
    it 'should not be able to have two same-type vendors' do
      subject.vendors << Vendor.create!(:name => 'extra voice vendor', :username => 'username2', :password => 'secret2', :from => 'from', :worker => 'TwilioVoiceWorker')
      subject.should_not be_valid
    end
  end
end
