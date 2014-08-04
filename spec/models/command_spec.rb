require 'spec_helper'

describe Command do
  let(:vendor){create(:sms_vendor)}
  let(:account){create(:account, sms_vendor: vendor, :dcm_account_codes=>['acme'])}
  let(:dcm_subscribe_command) {
    Command.new(:name => "FOO",
                :command_type => :dcm_subscribe,
                :params => CommandParameters.new(:dcm_account_code => ["acme"], :dcm_topic_codes=>['XXX'])).tap{|c| c.account = account }
  }

  subject { build_dcm_unsubscribe_command( account ) }

  context "without a keyword" do
    subject { build(:command, keyword: nil) }
    it { should_not be_valid }
  end

  context "without an account" do
    context "with a special keyword" do
      subject { build(:dcm_subscribe_command, keyword: build(:account_help) ) }
      its(:errors) { should_not include(:keyword) }
    end
    context "with a custom keyword" do
      # Note: you could put a subscribe command on the help keyword - user control
      subject { build(:dcm_subscribe_command,
                      account: nil,
                      keyword: build(:custom_keyword) ).tap(&:valid?) }
      its(:errors) { should include(:account) }
    end
  end

  [:command_type].each do |field|
    context "when #{field} is empty" do
      before { subject.send("#{field}=", nil) }
      specify { subject.valid?.should be false }
    end
  end

  context "when name has more than 256 characters" do
    before { subject.name = 'A'*256 }
    specify { subject.should be_invalid }
  end

  context "when params has more than 4000 characters" do
    before { subject.params = {'dcm_account_codes' => ['A'*4001] } }
    specify { subject.should be_invalid }
  end

  context "when name is blank" do
    before { subject.name = nil; subject.save! }
    specify { subject.name.to_s.should == subject.command_type.to_s }
  end

  context "when name is present" do
    before { subject.save! }
    specify { subject.name.to_s.should_not == subject.command_type.to_s }
  end

  context 'when params are invalid' do
    before do
      subject.command_type = :dcm_subscribe
      subject.params = {'dcm_topic_codes' => 'THIS, SHOULD BE AN ARRAY'}
    end
    it 'should show an error on params' do
      subject.valid?.should be false
      subject.errors.should include :params
    end
  end

  context 'when params are a Hash' do
    before do
      subject.command_type = :dcm_subscribe
      subject.params = {'dcm_topic_codes' => ['THIS, SHOULD BE AN ARRAY'], 'dcm_account_code' => 'foo'}
    end
    it 'should cast to CommandParameters safely' do
      subject.params.should be_kind_of( CommandParameters )
    end
  end

  context "perform_async!" do
    before do
      # Command should combine its own (persisted) params with the incoming params, convert them to a
      # hash, and pass them to the worker invocation
      @expected = CommandParameters.new(:from => "+122222", :dcm_account_codes => ["foo"])
      @expected.expects(:command_id=)
      CommandType[subject.command_type].expects(:perform_async!).with(@expected)
    end
    specify { subject.call(@expected) }
  end

  def build_dcm_unsubscribe_command account
    build(:dcm_unsubscribe_command,
          account: account,
          keyword: build(:custom_keyword),
          params: build(:unsubscribe_command_parameters,
                        dcm_account_codes: Array(account.dcm_account_codes)))
  end
end
