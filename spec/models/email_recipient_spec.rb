require 'rails_helper'

describe EmailRecipient do
  let(:macros) {{'one' => 'one_value', 'five' => 'five_value', 'two' => 'two_value'}}
  let(:vendor) {create(:email_vendor)}
  let(:account) {create(:account, email_vendor: vendor, name: 'account', sid: 'foo')}
  let(:message_type) {create(:message_type, account: account)}
  let(:email_message) {create(:email_message, account: account, message_type: message_type)}
  let(:other_email) do
    em = create(:email_message, account: account)
    em.recipients.build(email: 'doo@doo.com')
    em.save
    em
  end
  let(:user) {User.create(email: 'admin@example.com', password: 'retek01!').tap { |u| u.account = account}}

  subject do
    r         = email_message.recipients.build
    r.message = email_message
    r
  end

  its(:email) {should be_nil}
  it {is_expected.not_to be_valid}

  context 'with an email' do
    before do
      subject.email = 'hi@man.com'
      subject.save!
    end
    it 'should have the correct ODM record designator' do
      expect(subject.to_odm).to eq("hi@man.com::#{subject.id}::#{subject.x_tms_recipient}")
    end
    it 'should be identifiable by x_tms_recipient' do
      expect(subject.class.from_x_tms_recipent(subject.x_tms_recipient)).to eq(subject)
    end
    it 'should have the right message sendable_recipients using Recipient#to_send' do
      other_email # init
      expect(email_message.sendable_recipients.all).to eq(email_message.recipients.all)
    end
    context 'and macros' do
      before do
        subject.macros = macros
        subject.save!
      end
      it 'should have the correct ODM record designator' do
        expect(subject.to_odm('five' => nil, 'one' => nil, 'two' => nil)).to eq("hi@man.com::#{subject.id}::#{subject.x_tms_recipient}::five_value::one_value::two_value")
        # remove one from default hash
        expect(subject.to_odm('five' => nil, 'two' => nil)).to eq("hi@man.com::#{subject.id}::#{subject.x_tms_recipient}::five_value::two_value")
        # merging in defaults
        expect(subject.to_odm('one' => nil, 'seven' => 'seven_value')).to eq("hi@man.com::#{subject.id}::#{subject.x_tms_recipient}::one_value::seven_value")
      end
    end

    context 'that is marked inconclusive' do
      it 'should invoke webhooks' do
        account.webhooks.create!(url: 'http://dudes.ruby', event_type: 'inconclusive')
        Webhook.any_instance.expects(:invoke).with(subject)
        subject.reload
        subject.mark_inconclusive!
        expect(subject.completed_at).to be nil
        expect(subject.ack).to be nil
        expect(subject.error_message).to be nil
      end
    end

    context 'that fails' do
      it 'should invoke webhooks' do
        account.webhooks.create!(url: 'http://dudes.ruby', event_type: 'failed')
        Webhook.any_instance.expects(:invoke).with(subject)
        subject.reload
        subject.failed!('ack', nil, 'this message is terrible')
        expect(subject.failed?).to be true
        expect(subject.ack).to eq 'ack'
        expect(subject.error_message).to eq 'this message is terrible'
      end

      it 'should not retry!' do
        subject.message.expects(:worker).never
        subject.retry!
      end
    end

    it 'should have a delayable transition class method' do
      # for sidekiq in case there are connection timeouts
      EmailRecipient.transition(subject.id, :sending!, 'ack')
      expect(subject.reload.sending?).to be true
    end

    context 'that is sending' do
      before do
        subject.sending!('ack')
      end

      it 'should set sent_at' do
        expect(subject.sent_at).not_to be_nil
      end

      it 'should retry!' do
        worker = mock("worker")
        subject.message.expects(:worker).returns(worker)
        worker.expects(:perform_in).with(10.seconds, {message_id: subject.message.id, recipient_id: subject.id})
        subject.retry!
      end

      context 'and is sent' do
        before do
          subject.sent!('ack', Time.now)
        end
        it 'should update the record' do
          subject.reload
          expect(subject.vendor).not_to be_nil
          expect(subject.completed_at).not_to be_nil
          expect(subject.ack).to eq('ack')
          expect(subject.sent?).to be true
        end
        it 'should save clicks' do
          expect(subject.email_recipient_clicks.count).to eq(0)
          subject.clicked!('http://foo.bar.com', Time.now)
          expect(subject.email_recipient_clicks.count).to eq(1)
        end
        it 'should save opens' do
          expect(subject.email_recipient_opens.count).to eq(0)
          subject.opened!('1.1.1.1', Time.now) # IMPOSSIBLE!!  NO WAY!! OH   MY   GOD
          expect(subject.email_recipient_opens.count).to eq(1)
        end

        context 'and bounces' do
          it 'should update error message and status' do
            Analytics::PublisherWorker.expects(:perform_inline_or_async).with(
              channel: 'email_channel',
              message: {uri: "bounced", v: '1', account_sid: subject.message.account.sid, message_id: subject.message.id, recipient_id: subject.id, error_message: 'boing!'})
            subject.hard_bounce!(nil, nil, 'boing!')
            expect(subject.error_message).to eq 'boing!'
            expect(subject.failed?).to be true
          end
        end

        context 'and ARFs' do
          it 'should update error message but not status' do
            Analytics::PublisherWorker.expects(:perform_inline_or_async).with(
              channel: 'email_channel',
              message: {uri: "arf", v: '1', account_sid: subject.message.account.sid, message_id: subject.message.id, recipient_id: subject.id, error_message: 'woof!'})
            subject.arf!(nil, nil, 'woof!')
            expect(subject.error_message).to eq 'woof!'
            expect(subject.sent?).to be true
          end
        end
      end
    end

    context 'status updates' do
      it 'should have an error_message' do
        failed_recipient = subject
        failed_recipient.failed!(:ack, Time.now, 'error_message')
        expect(failed_recipient.error_message).to eq 'error_message'
        expect(failed_recipient.failed?).to be true
      end

      it 'should truncate a too-long error message' do
        failed_recipient = subject
        failed_recipient.failed!(:ack, Time.now, 'a' * 600)
        expect(failed_recipient.error_message).to eq 'a' * 512
        expect(failed_recipient.failed?).to be true
      end

      it 'failed scope includes failed status ' do
        subject.failed!
        expect(EmailRecipient.failed).to include(subject)
      end

      it 'failed scope does not include canceled status' do
        subject.canceled!('ack')
        expect(EmailRecipient.failed).not_to include(subject)
      end

      it 'sent scope includes sent status' do
        subject.sent!('ack', nil)
        expect(EmailRecipient.sent).to include(subject)
      end

      it 'should publish failed transitions' do
        expected = {
          channel: 'email_channel',
          message: has_entries(v:             '1',
                               recipient_id:  subject.id,
                               message_id:    subject.message.id,
                               account_sid:   subject.message.account.sid,
                               uri:           'failed',
                               error_message: 'equine error')
        }
        Analytics::PublisherWorker.expects(:perform_inline_or_async).with(has_entries(expected))
        subject.failed!(nil, nil, 'equine error')
      end

      it 'should publish canceled transitions' do
        expected = {
          channel: 'email_channel',
          message: has_entries(v: '1',
                               recipient_id: subject.id,
                               message_id: subject.message.id,
                               account_sid: subject.message.account.sid,
                               uri: 'canceled')
        }
        Analytics::PublisherWorker.expects(:perform_inline_or_async).with(has_entries(expected))
        subject.canceled!('ack')
      end

      it 'should publish sent transitions' do
        the_time = Time.now
        expected = {
          channel: 'email_channel',
          message: has_entries(v: '1',
                               recipient_id: subject.id,
                               message_id: subject.message.id,
                               account_sid: subject.message.account.sid,
                               uri: 'sent',
                               recipient_email: subject.email,
                               account_id: subject.message.account.id,
                               message_type_label: subject.message.message_type.label,
                               message_type_code: subject.message.message_type.code,
                               sent_at: the_time)
        }
        Analytics::PublisherWorker.expects(:perform_inline_or_async).with(has_entries(expected))
        subject.sent!('ack', the_time)
      end

      context 'after receiving the message' do
        before do
          subject.sent!('ack', nil)
        end

        it 'publishes click events' do
          the_time = Time.now
          expected = {
            channel: 'email_channel',
            message: has_entries(v: '1',
                                 recipient_id: subject.id,
                                 message_id: subject.message.id,
                                 account_sid: subject.message.account.sid,
                                 uri: 'clicked',
                                 url: 'http://www.google.com',
                                 recipient_email: subject.email,
                                 account_id: subject.message.account.id,
                                 message_type_label: subject.message.message_type.label,
                                 message_type_code: subject.message.message_type.code,
                                 clicked_at: the_time)
          }
          Analytics::PublisherWorker.expects(:perform_inline_or_async).with(has_entries(expected))
          subject.clicked!('http://www.google.com', the_time)
        end

        it 'publishes arfs' do
          expected = {
            channel: 'email_channel',
            message: has_entries(v: '1',
                                 recipient_id: subject.id,
                                 message_id: subject.message.id,
                                 account_sid: subject.message.account.sid,
                                 uri: 'arf')
          }
          Analytics::PublisherWorker.expects(:perform_inline_or_async).with(has_entries(expected))
          subject.arf!(nil, nil, 'ok')
        end

        it "publishes open events" do
          the_time = Time.now
          expected = {
            channel: 'email_channel',
            message: has_entries(v: '1',
                                 recipient_id: subject.id,
                                 message_id: subject.message.id,
                                 account_sid: subject.message.account.sid,
                                 uri: 'opened',
                                 recipient_email: subject.email,
                                 account_id: subject.message.account.id,
                                 message_type_label: subject.message.message_type.label,
                                 message_type_code: subject.message.message_type.code,
                                 opened_at: the_time)
          }
          Analytics::PublisherWorker.expects(:perform_inline_or_async).with(has_entries(expected))
          subject.opened!('127.0.0.1', the_time)
        end

        it "publishes bounce events" do
          expected = {
            channel: 'email_channel',
            message: has_entries(v: '1',
                                 recipient_id: subject.id,
                                 message_id: subject.message.id,
                                 account_sid: subject.message.account.sid,
                                 uri: 'bounced')
          }
          Analytics::PublisherWorker.expects(:perform_inline_or_async).with(has_entries(expected))
          subject.hard_bounce!('ack', Time.now, 'bounce')
        end
      end
    end
  end

  context 'timeout_expired' do
    let(:vendor) {create(:email_vendor)}
    let(:account) {create(:account, email_vendor: vendor, name: 'account')}
    let(:messages) do
      [1, 2].map do |x|
        m = create(:email_message, account: account, body: "body #{x}")
        m.ready!([email: "from-message#{x}@example.com"])
        m.sending!
        m
      end
    end
    before do
      # less than a day ago
      messages[0].recipients.update_all(sent_at: 23.hours.ago)
      # more than a day ago
      messages[1].recipients.update_all(sent_at: 25.hours.ago)
    end

    it 'only finds recipients in sending status' do
      expect(EmailRecipient.timeout_expired.all).to match_array(messages[1].recipients.all)
      messages[0].recipients.update_all(status: 'new')
      messages[1].recipients.update_all(status: 'new')
      result = EmailRecipient.timeout_expired.all
      expect(result).to be_empty
    end
  end
end
