require 'rails_helper'

describe Command do
  let(:vendor){create(:sms_vendor)}
  let(:account){create(:account, sms_vendor: vendor, :dcm_account_codes=>['acme'])}
  let(:keyword){create(:keyword, account: account, name: "test")}
  let(:dcm_subscribe_command) {
    keyword.commands.create(name: "FOO", command_type: :dcm_subscribe,
                            params: CommandParameters.new(:dcm_account_code => ["acme"], :dcm_topic_codes=>['XXX']) )
  }

  subject { build_dcm_unsubscribe_command( account ) }

  context "without a keyword" do
    subject { build(:command, keyword: nil) }
    it { is_expected.not_to be_valid }
  end

  [:command_type].each do |field|
    context "when #{field} is empty" do
      before { subject.send("#{field}=", nil) }
      specify { expect(subject.valid?).to be false }
    end
  end

  context "when name has more than 256 characters" do
    before { subject.name = 'A'*256 }
    specify { expect(subject).to be_invalid }
  end

  context "when params has more than 4000 characters" do
    before { subject.params = {'dcm_account_codes' => ['A'*4001] } }
    specify { expect(subject).to be_invalid }
  end

  context "when name is blank" do
    before { subject.name = nil; subject.save! }
    specify { expect(subject.name.to_s).to eq(subject.command_type.to_s) }
  end

  context "when name is present" do
    before { subject.save! }
    specify { expect(subject.name.to_s).not_to eq(subject.command_type.to_s) }
  end

  context 'when params are invalid' do
    before do
      subject.command_type = :dcm_subscribe
      subject.params = {'dcm_topic_codes' => 'THIS, SHOULD BE AN ARRAY'}
    end
    it 'should show an error on params' do
      expect(subject.valid?).to be false
      expect(subject.errors).to include :params
    end
  end

  context 'when params are a Hash' do
    before do
      subject.command_type = :dcm_subscribe
      subject.params = {'dcm_topic_codes' => ['THIS, SHOULD BE AN ARRAY'], 'dcm_account_code' => 'foo'}
    end
    it 'should cast to CommandParameters safely' do
      expect(subject.params).to be_kind_of( CommandParameters )
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

  context 'process_response' do
    it "works" do
      http_response = stub('http_response')
      subject.command_strategy.expects(:process_response).with(subject.account, subject.params, http_response)
      subject.process_response({inbound_message_id: 1000}, http_response)
    end
  end

  context 'process_error' do
    it "works" do
      http_response = stub('http_response')
      subject.command_strategy.expects(:process_error).with(subject.params, http_response)
      subject.process_error({inbound_message_id: 1000}, http_response)
    end
  end


  def build_dcm_unsubscribe_command account
    build(:dcm_unsubscribe_command,
          keyword: build(:custom_keyword, account: account),
          params: build(:unsubscribe_command_parameters,
                        dcm_account_codes: Array(account.dcm_account_codes)))
  end
end
