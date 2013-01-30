require 'spec_helper'

describe Account do
  let(:from_address) { FromAddress.create!(from_email: 'hey@dude.test') }
  let(:email_vendor) { create_email_vendor }
  let(:sms_vendor) { create_sms_vendor }

  context 'with SMS vendor' do
    subject {
      Account.new(:name => 'name', :sms_vendor => sms_vendor)
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

  it 'should require a from address if it had an email vendor' do
    Account.new(name: 'name', email_vendor: email_vendor).should_not be_valid
    Account.new(name: 'name', from_address: from_address, email_vendor: email_vendor).should be_valid
  end
end
