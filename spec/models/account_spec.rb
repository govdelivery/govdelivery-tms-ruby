require 'spec_helper'

describe Account do
  subject {
    Account.new(:name => 'name', :sms_vendor => create_sms_vendor)
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
    it 'should call commands' do
      subject.add_command!(:params => CommandParameters.new(:dcm_account_codes => ['ACCOUNT_CODE']), :command_type => :dcm_unsubscribe)
      from = "123123123"
      Keyword.any_instance.expects(:execute_commands).never
      Command.any_instance.expects(:call).with(:from => from)
      subject.stop(:from => from)
    end
  end
end
