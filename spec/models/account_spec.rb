require 'rails_helper'

describe Account do
  let(:email_vendor) { create(:email_vendor) }
  let(:sms_vendor) { create(:sms_vendor) }
  let(:shared_sms_vendor) { create(:shared_sms_vendor) }
  let(:voice_vendor) { create(:voice_vendor) }

  it { should belong_to(:ipaws_vendor) }

  context 'from_email_allowed?' do
    subject {
      create(:account, email_vendor: email_vendor)
    }
    it 'should work' do
      subject.sid.should_not be nil
      subject.from_email_allowed?('randomemail@foo.com').should be false
      subject.from_email_allowed?(subject.default_from_address.from_email).should be true
      subject.from_email_allowed?(subject.default_from_address.from_email.upcase).should be true
      subject.from_email_allowed?(nil).should be false
    end
  end

  context 'with transformers' do
    subject { create(:account) }

    it "should be able to retrieve its transformer" do
      transformer = subject.transformers.create(content_type:"application/json", transformer_class: "blah")
      expect(subject.transformer_with_type("application/json")).to eq(transformer)
    end
  end

  context 'with shared SMS vendor' do
    subject { build(:account_with_sms, :shared) }

    context "without prefixes" do
      it { should_not be_valid }
    end

    context "with prefixes" do
      subject { create(:account_with_sms, :shared, prefix: 'other-pirate') }
      it { should be_valid }
      it 'can have multiple prefixes' do
        subject.save!
        subject.sms_prefixes.create! prefix: 'name01'
        subject.sms_prefixes.create! prefix: 'name02'
        subject.sms_vendor.sms_prefixes.count.should eql( 3 )
      end
    end

  end

  context 'with exclusive SMS vendor' do
    subject {
      Account.new(name: 'name', sms_vendor: sms_vendor, dcm_account_codes: ['ACCOUNT_CODE'])
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

    context "when link_encoder is nil" do
      before { subject.link_encoder = nil }
      it { should be_valid }
    end

    # HYRULE
    context "when link_encoder is ONE" do
      before { subject.link_encoder = 'ONE' }
      it { should be_valid }
    end

    # STRONGMAIL
    context "when link_encoder is TWO" do
      before { subject.link_encoder = 'TWO' }
      it { should be_valid }
    end

    context "when link_encoder is invalid" do
      before { subject.link_encoder = 'blah' }
      it { should_not be_valid }
    end

    context 'creating a command' do
      it 'can create a command on a keyword on the fly' do
        account = create(:account_with_sms)
        command = account.create_command!('fly', params: build(:forward_command_parameters), command_type: 'forward')
        command.keyword.account.should eql(account)
      end
    end
    context "calling stop" do
      it 'should call commands' do
        account = create(:account_with_sms, dcm_account_codes: ['ACCOUNT_CODE'])
        account.stop_keyword.should_not be_nil
        command_params = mock()
        params = CommandParameters.new(dcm_account_codes: ['ACCOUNT_CODE'])
        account.stop_keyword.create_command!(params: params, command_type: :dcm_unsubscribe)
        Keyword.any_instance.expects(:execute_commands).never
        Command.any_instance.expects(:call).with(command_params)
        account.stop(command_params)
      end
    end

    context "calling stop!" do
      context "with no existing stop requests" do
        it 'should create a stop request and call commands' do
          account = create(:account_with_sms, dcm_account_codes: ['ACCOUNT_CODE'])
          command_params = stub(:account_id= => true, from: "BOBBY")
          account.stop_keyword.create_command!(params: CommandParameters.new(dcm_account_codes: ['ACCOUNT_CODE']),
                                  command_type: :dcm_unsubscribe)
          Command.any_instance.expects(:call).with(command_params)
          expect {
            account.stop!(command_params)
          }.to change { account.stop_requests.count }.by 1
        end
      end
      context 'with existing stop request for this phone' do
        it 'should not create another stop request, but should call stop' do
          subject.expects(:stop_requests).returns(stub(:exists? => true))
          subject.expects(:stop) # non-bang method should be called.
          subject.stop!(mock(from: "8888"))
        end
      end
    end
  end

  it 'should require a from address if it had an email vendor' do
    Account.new(name: 'name', email_vendor: email_vendor).should_not be_valid
    a = Account.new(name: 'name', email_vendor: email_vendor)
    a.from_addresses.build(from_email: 'shanty@example.com')
    a.should_not be_valid

    a.from_addresses.first.is_default = true
    a.should be_valid
  end

  it 'should require a from number if it had a voice vendor' do
    Account.new(name: 'name', voice_vendor: voice_vendor).should_not be_valid
    a = Account.new(name: 'name', voice_vendor: voice_vendor)
    a.from_numbers.build(phone_number: '8885551234')
    a.should_not be_valid

    a.from_numbers.first.is_default = true
    a.should be_valid
  end

  it 'has some sugar for the EN peeps' do
    account = create(:account_with_sms)
    account.keywords.create!(name: 'what')
    account.keywords('what').should be_kind_of(Keyword)
    account.keywords('what!').should be_nil
  end

  context 'an account with lots of stuff that is destroyed' do
    before do
      @tables = ActiveRecord::Base.connection.tables
      @tables.delete('schema_migrations')
      @tables.each do |table|
        ActiveRecord::Base.connection.select_value("select count(*) from #{table}").should eq 0
      end
      @account    = create(:account_with_stuff)
      @account_id = @account.id
      @account.destroy
    end
    it 'is rad' do
      direct_tables = ActiveRecord::Base.connection.tables.
        map { |m| m.classify.constantize rescue nil }.compact.
        select { |m| m.column_names.include?('account_id') }

      direct_tables.each do |klass|
        expect(klass.where(account_id: @account_id).count).to eq 0
      end

      (@tables - direct_tables).each do |table|
        expect(ActiveRecord::Base.connection.select_value("select count(*) from #{table}")).to eq 0
      end
    end
  end

  it 'should validate that it cannot be added to a non-shared vendor who already has an account' do
    second_account = create(:account_with_sms)
    vendor = create(:sms_vendor)
    account = create(:account_with_sms, sms_vendor: vendor)
    vendor.shared = false
    vendor.save!
    second_account.sms_vendor = vendor
    second_account.valid?.should == false
  end
end
