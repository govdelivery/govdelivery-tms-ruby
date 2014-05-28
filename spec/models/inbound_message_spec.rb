require 'spec_helper'

describe InboundMessage do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
  let(:keyword) { create(:custom_keyword, account: account, vendor: vendor, name: 'HI') }
  let(:command) { keyword.create_command!(command_type: :forward,
                                          name: "ALLIGATORZ",
                                          params: build(:forward_command_parameters)) }
  let(:command2) { keyword.create_command!(command_type: :forward,
                                           name: "CROCZZZ",
                                           params: build(:forward_command_parameters)) }

  let(:inbound_message) { InboundMessage.create!(vendor: vendor,
                                                 body: 'this is my body',
                                                 from: '5551112222',
                                                 keyword: keyword) }

  let(:inbound_message_with_response) { InboundMessage.create!(vendor: vendor,
                                                               body: 'this is my body',
                                                               from: '5551112222',
                                                               keyword_response: 'respondzzz') }
  subject { inbound_message }

  context "when valid" do
    specify { subject.valid?.should == true }
  end

  [:body, :from].each do |field|
    context "when #{field} is empty" do
      before { subject.send("#{field}=", nil) }
      specify { subject.valid?.should == false }
    end
  end

  it 'should be complete if response is supplied' do
    inbound_message_with_response.command_status.should eq(:success)
  end


  context 'a message saved with a command' do
    before do
      command
      command2
    end
    it 'should be pending' do
      inbound_message.command_status.should eq(:pending)
    end
    context 'and then updated' do
      before do
        command.command_actions.create!(inbound_message_id: inbound_message.id,
                                        status: 200,
                                        content_type: 'text/html')
      end
      it 'should be in progress' do
        inbound_message.reload.command_status.should eq(:pending)
      end

      context 'and then completed' do
        before do
          command.command_actions.create!(inbound_message_id: inbound_message.id,
                                          status: 204,
                                          content_type: 'text/html')
        end
        it 'should be complete' do
          inbound_message.reload.command_status.should eq(:success)
        end
      end

    end
  end

  context "auto-responses" do
    before do
      inbound_message_with_response
    end

    it 'should not be actionable' do
      inbound_message_with_response.actionable?.should eq(true)

      dup_inbound_message =  InboundMessage.create!(vendor: inbound_message_with_response.vendor,
                                body: inbound_message_with_response.body,
                                from: inbound_message_with_response.from,
                                keyword_response: inbound_message_with_response.keyword_response)

      dup_inbound_message.actionable?.should eq(false)

      # it shouldn't matter if id is nil
      old_id = dup_inbound_message.id
      dup_inbound_message.id = nil
      dup_inbound_message.actionable?.should eq(false)
      dup_inbound_message.id = old_id

      # The body should be the same...
      dup_inbound_message.body = dup_inbound_message.body * 2
      dup_inbound_message.actionable?.should eq(true)

      # The from (i.e. caller_phone) should be the same...
      dup_inbound_message.reload
      dup_inbound_message.actionable?.should eq(false)
      dup_inbound_message.from = dup_inbound_message.from * 2
      dup_inbound_message.actionable?.should eq(true)

      # The created time should be within a configured window...
      dup_inbound_message.reload
      dup_inbound_message.actionable?.should eq(false)
      dup_inbound_message.created_at = (dup_inbound_message.created_at +
                                       Xact::Application.config.auto_response_threshold.minutes +
                                       1.minute).to_datetime

      dup_inbound_message.actionable?.should eq(true)
    end
  end


end
