require 'rails_helper'

describe Account do
  let(:email_vendor) { create(:email_vendor) }
  let(:sms_vendor) { create(:sms_vendor) }
  let(:shared_sms_vendor) { create(:shared_sms_vendor) }
  let(:voice_vendor) { create(:voice_vendor) }

  it { is_expected.to belong_to(:ipaws_vendor) }

  context 'from_email_allowed?' do
    subject {
      create(:account, email_vendor: email_vendor)
    }
    it 'should work' do
      expect(subject.sid).not_to be nil
      expect(subject.from_email_allowed?('randomemail@foo.com')).to be false
      expect(subject.from_email_allowed?(subject.default_from_address.from_email)).to be true
      expect(subject.from_email_allowed?(subject.default_from_address.from_email.upcase)).to be true
      expect(subject.from_email_allowed?(nil)).to be false
    end
  end

  context 'with shared SMS vendor' do
    subject { build(:account_with_sms, :shared) }

    context "without prefixes" do
      it { is_expected.not_to be_valid }
    end

    context "with prefixes" do
      subject { create(:account_with_sms, :shared, prefix: 'other-pirate') }
      it { is_expected.to be_valid }
      it 'can have multiple prefixes' do
        subject.save!
        subject.sms_prefixes.create! prefix: 'name01'
        subject.sms_prefixes.create! prefix: 'name02'
        expect(subject.sms_vendor.sms_prefixes.count).to eql( 3 )
      end
    end

  end

  context 'with exclusive SMS vendor' do
    subject {
      Account.new(name: 'name', sms_vendor: sms_vendor, dcm_account_codes: ['ACCOUNT_CODE'])
    }

    it { is_expected.to be_valid }

    context "when name is empty" do
      before { subject.name = nil }
      it { is_expected.not_to be_valid }
    end

    context "when name too long" do
      before { subject.name = "W"*257 }
      it { is_expected.not_to be_valid }
    end

    context "when link_encoder is nil" do
      before { subject.link_encoder = nil }
      it { is_expected.to be_valid }
    end

    # HYRULE
    context "when link_encoder is ONE" do
      before { subject.link_encoder = 'ONE' }
      it { is_expected.to be_valid }
    end

    # STRONGMAIL
    context "when link_encoder is TWO" do
      before { subject.link_encoder = 'TWO' }
      it { is_expected.to be_valid }
    end

    context "when link_encoder is invalid" do
      before { subject.link_encoder = 'blah' }
      it { is_expected.not_to be_valid }
    end

    context 'creating a command' do
      it 'can create a command on a keyword on the fly' do
        account = create(:account_with_sms)
        command = account.create_command!('fly', params: build(:forward_command_parameters), command_type: 'forward')
        expect(command.keyword.account).to eql(account)
      end
    end
    context "calling stop" do
      it 'should call commands' do
        account = create(:account_with_sms, dcm_account_codes: ['ACCOUNT_CODE'])
        expect(account.stop_keyword).not_to be_nil
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

  context 'Link Tracking Parameters' do
    it 'should default to blank' do
      a = create(:account, email_vendor: email_vendor)
      expect(a).to be_valid
      expect(a.link_tracking_parameters).to be_blank
      expect(a.link_tracking_parameters_hash).to eq({})
    end

    it 'should use supplied values' do
      a = create(:account, email_vendor: email_vendor, link_tracking_parameters:"foo=bar&pi=3")
      expect(a).to be_valid
      expect(a.link_tracking_parameters).to eq("foo=bar&pi=3")
      expect(a.link_tracking_parameters_hash).to eq({"foo" => "bar", "pi" => "3"})
      a.link_tracking_parameters = "not_foo=true"
      a.save!
      expect(a.link_tracking_parameters).to eq("not_foo=true")
      expect(a.link_tracking_parameters_hash).to eq({"not_foo" => "true"})
    end

    it 'should return nothing with blank tracking parameters' do
      a = create(:account, email_vendor: email_vendor, link_tracking_parameters:"")
      expect(a).to be_valid
      expect(a.link_tracking_parameters).to be_blank
      expect(a.link_tracking_parameters_hash).to eq({})
    end

    it 'should be nilable' do
      a = create(:account, email_vendor: email_vendor, link_tracking_parameters:nil)
      expect(a).to be_valid
      expect(a.link_tracking_parameters).to be_blank
      expect(a.link_tracking_parameters_hash).to eq({})
      a.link_tracking_parameters = "this=something"
      a.save!
      expect(a.link_tracking_parameters).to_not be_blank
      expect(a.link_tracking_parameters_hash).to_not eq({})
      a.link_tracking_parameters = nil
      a.save!
      expect(a.link_tracking_parameters).to be_blank
      expect(a.link_tracking_parameters_hash).to eq({})
    end
  end

  it 'should require a from address if it had an email vendor' do
    expect(Account.new(name: 'name', email_vendor: email_vendor)).not_to be_valid
    a = Account.new(name: 'name', email_vendor: email_vendor)
    a.from_addresses.build(from_email: 'shanty@example.com')
    expect(a).not_to be_valid

    a.from_addresses.first.is_default = true
    expect(a).to be_valid
  end

  it 'should require a from number if it had a voice vendor' do
    expect(Account.new(name: 'name', voice_vendor: voice_vendor)).not_to be_valid
    a = Account.new(name: 'name', voice_vendor: voice_vendor)
    a.from_numbers.build(phone_number: '8885551234')
    expect(a).not_to be_valid

    a.from_numbers.first.is_default = true
    expect(a).to be_valid
  end

  it 'has some sugar for the EN peeps' do
    account = create(:account_with_sms)
    account.keywords.create!(name: 'what')
    expect(account.keywords('what')).to be_kind_of(Keyword)
    expect(account.keywords('what!')).to be_nil
  end

  context 'an account with lots of stuff that is destroyed' do
    before do
      @tables = ActiveRecord::Base.connection.tables
      @tables.delete('schema_migrations')
      @tables.each do |table|
        expect(ActiveRecord::Base.connection.select_value("select count(*) from #{table}")).to eq 0
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
    expect(second_account.valid?).to eq(false)
  end
end
