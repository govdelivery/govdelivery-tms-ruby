# encoding: UTF-8
require 'spec_helper'

describe Keyword do
  subject { create(:account_keyword) }

  context "when name is valid" do
    its(:errors) { should be_empty }
  end

  context "when name is empty" do
    subject{ build(:keyword, name: nil).tap(&:valid?) }
    its(:errors) { should include(:name) }
  end

  context "when name has a space" do
    subject{ build(:keyword, name: "a b").tap(&:valid?) }
    its(:errors) { should include(:name) }
  end

  context "when response_text is empty" do
    subject{ build(:keyword, response_text: nil).tap(&:valid?) }
    its(:errors) { should_not include(:response_text) }
  end

  [:name, :response_text].each do |field|
    context "when #{field} is too long" do
      before { subject.send("#{field}=", 'A'*161) }
      specify { subject.should be_invalid }
    end
  end

  context "with duplicate name and same vendor" do

    before do
      subject.save!
      @new_keyword = Keyword.new(:name => subject.name)
      @new_keyword.account = subject.account
      @new_keyword.vendor  = subject.vendor
    end
    specify { @new_keyword.should be_invalid }

    context "and same vendor but different account_id" do
      before do
        @new_keyword.account = create(:account, sms_vendor: subject.vendor)
        @new_keyword.vendor = subject.vendor
      end
      specify do
        @new_keyword.should be_valid
        @new_keyword.save! # make sure there is no index preventing this anymore
      end
    end
  end

  context 'special keywords' do
    describe 'AccountStop' do
      subject{ account_stop_keyword_with_forward_command }

      it 'get a special class' do
        # special keywords are created through accounts or vendors
        vendor = create(:sms_vendor)
        special_keywords = vendor.keywords.collect(&:class)
        special_keywords.should include(Keywords::VendorStop)
        special_keywords.should include(Keywords::VendorHelp)
        special_keywords.should include(Keywords::VendorDefault)
      end

      it 'does not downcase the name' do
        subject.name = 'FOOBAR'
        subject.name.should == 'FOOBAR'
      end

      context '#execute_commands' do
        context 'AccountStop' do
          subject{ account_stop_keyword_with_forward_command }
          it 'should call Account#stop!' do
            subject.account.expects(:stop!)
            subject.execute_commands(build(:forward_command_parameters))
          end
        end
      end
    end
  end

  describe 'custom keyword' do
    subject { create(:custom_keyword) }
    describe '#name=' do

      it 'downcases the name' do
        subject.should be_instance_of(Keyword)
        subject.name = 'FOOBAR'
        subject.name.should == 'foobar'
      end

      it 'handles non-ascii' do
        subject.name = 'SÜSCRÍBÁSÉÑ'
        subject.name.should == 'süscríbáséñ'
      end

      it 'strips whitespace' do
        subject.name = " foobar \n"
        subject.name.should == 'foobar'
      end

      %w(stop quit help).each do |name|
        it "doesn't allow a '#{name}' keyword to be created" do
          subject.name = name
          subject.should_not be_valid
        end

        it "doesn't allow '#{name}' as the first word in a multi-word keyword" do
          subject.name = "#{name} more words"
          subject.should_not be_valid
        end

        it "doesn't allow '#{name}' as the first word in a multi-word keyword separated by non-space characters" do
          subject.name = "#{name}\nmore\nwords"
          subject.should_not be_valid
        end

        it "DOES allow a keyword to start with a word beginning with '#{name}' to be created" do
          subject.name = "#{name}word"
          subject.should be_valid
        end

        it "does not allow multiword keywords" do
          subject.name = 'some more words'
          subject.should_not be_valid
        end

      end
    end
  end

  describe '#create_command!' do
    let(:command){ stub('Command', call: true) }
    let(:command_params){ CommandParameters.new }
    subject { create(:sms_vendor).stop_keyword }


    it 'creates a command' do
      expect {
        dcm_account_codes = subject.vendor.accounts.map(&:dcm_account_codes).reduce(:+).to_a
        subject.create_command!(:params => CommandParameters.new(:dcm_account_codes => dcm_account_codes),
                             :command_type => :dcm_unsubscribe)
      }.to change{Command.count}.by 1
    end

    it 'a vendor default keyword can have a forward command' do
      keyword = create(:vendor_default)
      CommandType::Forward.any_instance.expects(:perform_async!).with(kind_of(CommandParameters))

      keyword.create_command!(params: {
                                command_type: :forward,
                                http_method: 'POST',
                                url: 'http://what.cd' },
                              command_type: :forward  )
      keyword.commands.first.call(CommandParameters.new( account_id: '4'))
    end

    it "requires valid CommandParameters" do
      keyword = create(:account_keyword)
      # in this case the dcm_account_codes have to be a subset of vendor.accounts.map(&:dcm_account_codes)
      expect {
        # zanzabar doesn't exist silly
        keyword.create_command!(:params => CommandParameters.new(:dcm_account_codes => ['zanzabar']),
                                :command_type => :dcm_unsubscribe)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'Keyword.get_keyword can retreive a forward keyword command' do
      account = create(:account_with_sms, :shared, prefix: 'pirate')

      account.create_command!('plunder', { params: { command_type: :forward,
                                                 http_method: 'POST',
                                                 url: 'http://what.cd' },
                                        command_type: :forward })
      account.keywords.pluck(:name).should include('plunder')
      keyword = Keyword.get_keyword('plunder', account.sms_vendor, account.id )
      keyword.should be_instance_of(Keyword)
      keyword.name.should eql('plunder')
    end

  end


  describe 'stop?' do
    %w(stop quit STOP QUIT sToP qUiT cancel unsubscribe).each do |stop|
      it "should recognize #{stop}" do
        Keyword.stop?(stop).should be_true
      end
    end
  end

  context 'Keyword.get_keywords' do

    before { @account = create(:account_with_sms) }
    describe 'given only a vendor' do
      subject{ Keyword.get_keyword nil, build(:sms_vendor), nil }
      it { should be_instance_of(Keywords::VendorDefault) }
    end

    describe 'given a vendor and an account_id' do
      subject{ Keyword.get_keyword( nil, build(:sms_vendor), @account.id ) }
      it { should be_instance_of(Keywords::AccountDefault) }
    end

    describe 'given a vendor and an account without sms' do
      before { @account = create(:account) }
      subject{ Keyword.get_keyword( nil, build(:sms_vendor), @account.id ) }
      it { should be_nil }
    end

    describe "given a vendor and an account and keyword: 'help' " do
      subject{ Keyword.get_keyword( 'help', build(:sms_vendor), @account.id ) }
      it { should be_instance_of( Keywords::AccountHelp) }
    end

    describe "given a vendor and an account and keyword: 'info' " do
      subject{ Keyword.get_keyword( 'help', build(:sms_vendor), @account.id ) }
      it { should be_instance_of( Keywords::AccountHelp) }
    end

    describe "given a vendor and an account and keyword: 'stop' " do
      subject{ Keyword.get_keyword( 'stop', build(:sms_vendor), @account.id ) }
      it { should be_instance_of( Keywords::AccountStop) }
    end

    describe "given a vendor and keyword: 'start' " do
      subject{ Keyword.get_keyword( 'start', build(:sms_vendor), nil) }
      it { should be_instance_of( Keywords::VendorStart) }
    end

    describe "given a vendor and an account keyword: 'start' because there is no AccountStart " do
      subject{ Keyword.get_keyword( 'start', build(:sms_vendor), @account.id) }
      it { should be_instance_of( Keywords::AccountDefault) }
    end

    describe "given a vendor and an account and keyword: 'unsubscribe' " do
      subject{ Keyword.get_keyword( 'unsubscribe', build(:sms_vendor), @account.id ) }
      it { should be_instance_of( Keywords::AccountStop) }
    end

    describe "given a vendor and an account and keyword: 'plunder'  " do
      before do
        account = create(:account_with_sms, :shared, prefix: 'pirate')
        account.create_command!('plunder', params: build(:forward_command_parameters).to_hash, command_type: 'forward')
      end
      subject{ Keyword.get_keyword( 'stop', build(:sms_vendor), @account.id ) }
      it { should be_instance_of( Keywords::AccountStop) }
    end

    describe "given a vendor and an account and keyword: 'nothing' " do
      subject{ Keyword.get_keyword( 'nothing', build(:sms_vendor), @account.id ) }
      it { should be_instance_of( Keywords::AccountDefault) }
    end


  end

  def account_stop_keyword_with_forward_command
    keyword = create(:account_with_sms).stop_keyword
    keyword.create_command!( params: build(:forward_command_parameters), command_type: :forward )
    keyword
  end
end
