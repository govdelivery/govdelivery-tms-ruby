require 'rails_helper'

describe InboundMessage do

  subject { build_stubbed(:inbound_message) }
  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of( :body ) }
  it { is_expected.to validate_presence_of( :from ) }
  it { is_expected.to validate_presence_of( :vendor ) }

  it 'is ignored if not actionable' do
    subject.expects(:actionable?).returns(false)
    subject.expects(:save!).returns(true)
    subject.send(:see_if_this_should_be_ignored)
    expect(subject.command_status).to eql(:ignored)
  end

  context 'setting response status' do
    it 'should be :success if the keyword has no commands and response_text ' do
      inbound_message = build_stubbed(:inbound_message,
                                      keyword: build_stubbed(:keyword, commands: [], response_text: 'something'))
      inbound_message.send :set_response_status
      expect(inbound_message.command_status).to eql(:success)
    end

    it 'should be :pending if the keyword has any commands and response_text ' do
      inbound_message = build_stubbed(:inbound_message,
                                      keyword: build_stubbed(:keyword, commands: [build(:forward_command)]))
      inbound_message.send :set_response_status
      expect(inbound_message.command_status).to eql(:pending)
    end

    it 'should be :no_action if the keyword has no commands and no response_text ' do
      inbound_message = build_stubbed(:inbound_message,
                                      keyword: build_stubbed(:keyword, response_text: nil, commands: []))
      inbound_message.send :set_response_status
      expect(inbound_message.command_status).to eql(:no_action)
    end

    context 'updating the pending status' do
      before do
        @inbound_message = create(:inbound_message,
                                  keyword: create(:custom_keyword, response_text: nil).
                                    tap { |k| k.commands << build(:forward_command)}.
                                    tap { |k| k.commands << build(:forward_command)})

      end
      it 'should be :pending after one of two commands have completed' do
        expect(@inbound_message.command_status).to eql(:pending)
        @inbound_message.command_actions.create!(response_body: 'foo', status: 201) # one of two
        @inbound_message.update_status!
        expect(@inbound_message.command_status).to eql(:pending)
      end

      it 'should be :success after two of two commands have completed' do
        expect(@inbound_message.command_status).to eql(:pending)
        @inbound_message.command_actions.create!(response_body: 'foo', status: 201) # one of two
        @inbound_message.command_actions.create!(response_body: 'foo', status: 201) # two of two
        @inbound_message.update_status!
        expect(@inbound_message.command_status).to eql(:success)
      end

      it 'should be :failure if told to fail once' do
        expect(@inbound_message.command_status).to eql(:pending)
        @inbound_message.update_status! fail=true
        expect(@inbound_message.command_status).to eql(:failure)
        @inbound_message.update_status! fail=false
        expect(@inbound_message.command_status).to eql(:failure) #still a failure
      end

    end

  end

  context "auto-responses" do
    let(:inbound_message_with_response) do
      create(:inbound_message,
             keyword: create(:custom_keyword, response_text: 'respondzzz'),
             body: 'this is my body',
             from: '5551112222')
    end
    let(:dup_inbound_message) do
      create(:inbound_message,
             keyword: create(:custom_keyword, response_text: 'respondzzz'),
             body: 'this is my body',
             from: '5551112222')
    end
    it 'should not be actionable' do
      expect(inbound_message_with_response.actionable?).to eq(true)

      expect(dup_inbound_message.actionable?).to eq(false)

      # it shouldn't matter if id is nil
      old_id = dup_inbound_message.id
      dup_inbound_message.id = nil
      expect(dup_inbound_message.actionable?).to eq(false)
      dup_inbound_message.id = old_id

      # The body should be the same...
      dup_inbound_message.body = dup_inbound_message.body * 2
      expect(dup_inbound_message.actionable?).to eq(true)

      # The from (i.e. caller_phone) should be the same...
      dup_inbound_message.reload
      expect(dup_inbound_message.actionable?).to eq(false)
      dup_inbound_message.from = dup_inbound_message.from * 2
      expect(dup_inbound_message.actionable?).to eq(true)

      # The created time should be within a configured window...
      dup_inbound_message.reload
      expect(dup_inbound_message.actionable?).to eq(false)
      dup_inbound_message.created_at = (dup_inbound_message.created_at +
                                        Xact::Application.config.auto_response_threshold.minutes +
                                        1.minute).to_datetime

      expect(dup_inbound_message.actionable?).to eq(true)
    end
  end

  it 'can be scoped to an account' do
    create_list(:inbound_message, 3, account: (account = create(:account_with_sms)))
    expect(InboundMessage.where(account_id: account.id).count).to eql(3)
  end

  it 'publishes an event on create' do
    message = build(:inbound_message,
                      keyword: create(:custom_keyword, response_text: nil).
                        tap { |k| k.commands << build(:forward_command)}.
                        tap { |k| k.commands << build(:forward_command)})

    expected = {
      channel: 'sms_channel',
      message: has_entries({
        v: '1',
        to_phone: message.to,
        from_phone: message.from,
        body: message.body,
        uri: 'xact:sms:inbound'
      })
    }
    Analytics::PublisherWorker.expects(:perform_async).with(has_entries(expected))
    message.save!
  end
end
