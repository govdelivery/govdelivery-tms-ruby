require 'spec_helper'

describe Account do
  let(:email_vendor) { create(:email_vendor) }
  let(:sms_vendor) { create(:sms_vendor) }
  let(:shared_sms_vendor) { create(:shared_sms_vendor) }

  it { should belong_to(:ipaws_vendor) }

  context 'from_email_allowed?' do
    subject {
      create(:account, email_vendor: email_vendor)
    }
    it 'should work' do
      subject.from_email_allowed?('randomemail@foo.com').should be_false
      subject.from_email_allowed?(subject.default_from_address.from_email).should be_true
      subject.from_email_allowed?(subject.default_from_address.from_email.upcase).should be_true
      subject.from_email_allowed?(nil).should be_false
    end
  end

  context 'with shared SMS vendor' do
    subject {
      Account.new(:name => 'name', :sms_vendor => shared_sms_vendor, :dcm_account_codes=> ['ACCOUNT_CODE'])
    }

    context "without prefixes" do
      it { should_not be_valid }
    end

    context "with prefixes" do
      before { subject.sms_prefixes.build(:prefix => 'FOO') }
      it { should be_valid }
    end    
  end

  [:help_text, :stop_text].each do |item|
    context "##{item}" do
      subject {
        Account.new(:name => 'name', :sms_vendor => shared_sms_vendor, :dcm_account_codes=> ['ACCOUNT_CODE'])
      }

      context "when nil" do
        it { subject.send(item).should eq(shared_sms_vendor.send(item)) }
      end

      context "when not nil" do
        before {subject.send("#{item}=", "something")}
        it { subject.send(item).should eq("something")}
      end
      it 'should return nil without an SmsVendor' do
        a=Account.new(:name => 'name', :sms_vendor => nil, :dcm_account_codes=> ['ACCOUNT_CODE'])
        a.send(item).should be_nil
      end
    end
  end
  context 'with exclusive SMS vendor' do
    subject {
      Account.new(:name => 'name', :sms_vendor => sms_vendor, :dcm_account_codes=> ['ACCOUNT_CODE'])
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
        command_params = mock(:account_id= => true )
        subject.add_command!(:params => CommandParameters.new(:dcm_account_codes => ['ACCOUNT_CODE']), :command_type => :dcm_unsubscribe)
        Keyword.any_instance.expects(:execute_commands).never
        Command.any_instance.expects(:call).with(command_params)
        subject.stop(command_params)
      end
    end

    context "calling stop!" do
      context "with no existing stop requests" do
        it 'should create a stop request and call commands' do
          command_params = stub(:account_id= => true, :from => "BOBBY")
          subject.add_command!(:params => CommandParameters.new(:dcm_account_codes => ['ACCOUNT_CODE']), :command_type => :dcm_unsubscribe)
          Command.any_instance.expects(:call).with(command_params)
          expect {
            subject.stop!(command_params)
          }.to change { subject.stop_requests.count }.by 1
        end
      end
      context 'with existing stop request for this phone' do
        it 'should not create another stop request, but should call stop' do
          subject.expects(:stop_requests).returns(stub(:exists? => true))
          subject.expects(:stop) # non-bang method should be called. 
          subject.stop!(mock(:from => "8888"))
        end
      end
    end
  end

  it 'should require a from address if it had an email vendor' do
    Account.new(name: 'name', email_vendor: email_vendor).should_not be_valid
    a = Account.new(name: 'name', email_vendor: email_vendor)
    a.from_addresses.build(:from_email => 'shanty@example.com')
    a.should_not be_valid

    a.from_addresses.first.is_default = true
    a.should be_valid
  end
end
