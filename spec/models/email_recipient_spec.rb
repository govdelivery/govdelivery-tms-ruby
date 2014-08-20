require 'rails_helper'

describe EmailRecipient do
  let(:macros) { {'one' => 'one_value', 'five' => 'five_value', 'two' => 'two_value'} }
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor, name: 'account') }
  let(:email_message) { create(:email_message, account: account) }
  let(:other_email) {
    em = create(:email_message, account: account)
    em.recipients.build(email: 'doo@doo.com')
    em.save
    em
  }
  let(:user) { User.create(:email => 'admin@example.com', :password => 'retek01!').tap { |u| u.account = account } }

  subject {
    r         = email_message.recipients.build
    r.message = email_message
    r
  }

  its(:email) { should be_nil }
  it { should_not be_valid }

  context 'with an email' do
    before do
      subject.email='hi@man.com'
      subject.save!
    end
    it 'should have the correct ODM record designator' do
      subject.to_odm.should eq("hi@man.com::#{subject.id}")
    end
    it 'should have the right message sendable_recipients using Recipient#to_send' do
      other_email #init
      email_message.sendable_recipients.all.should eq(email_message.recipients.all)
    end
    context 'and macros' do
      before do
        subject.macros = macros
        subject.save!
      end
      it 'should have the correct ODM record designator' do
        subject.to_odm('five' => nil, 'one' => nil, 'two' => nil).should eq("hi@man.com::#{subject.id}::five_value::one_value::two_value")
        # remove one from default hash
        subject.to_odm('five' => nil, 'two' => nil).should eq("hi@man.com::#{subject.id}::five_value::two_value")
        # merging in defaults
        subject.to_odm({'one' => nil, 'seven' => 'seven_value'}).should eq("hi@man.com::#{subject.id}::one_value::seven_value")
      end
    end
    context 'that fails' do
      it 'should invoke webhooks' do
        account.webhooks.create!(url: 'http://dudes.ruby', event_type: 'failed')
        Webhook.any_instance.expects(:invoke).with(subject)
        subject.reload
        subject.failed!('ack', 'this message is terrible')
        subject.failed?.should be true
      end
    end

    context 'that is sending' do
      before do
        subject.sending!('ack')
      end

      it 'should set sent_at' do
        subject.sent_at.should_not be_nil
      end

      context 'that is sent' do
        before do
          subject.sent!('ack', Time.now)
        end
        it 'should update the record' do
          subject.reload
          subject.vendor.should_not be_nil
          subject.completed_at.should_not be_nil
          subject.ack.should eq('ack')
          subject.sent?.should be true
        end
        it 'should save clicks' do
          subject.email_recipient_clicks.count.should == 0
          subject.clicked!("http://foo.bar.com", DateTime.now)
          subject.email_recipient_clicks.count.should == 1
        end
        it 'should save opens' do
          subject.email_recipient_opens.count.should == 0
          subject.opened!("1.1.1.1", DateTime.now) # IMPOSSIBLE!!  NO WAY!! OH   MY   GOD
          subject.email_recipient_opens.count.should == 1
        end
      end
    end

    context 'status updates' do
      it 'should have an error_message' do
        failed_recipient = subject
        failed_recipient.failed!(:ack, 'error_message', (sent_at = Time.now))
        failed_recipient.error_message.should eq 'error_message'
        failed_recipient.failed?.should be true
      end

      it 'should truncate a too-long error message' do
        failed_recipient = subject
        failed_recipient.failed!(:ack, 'a' * 600, (sent_at = Time.now))
        failed_recipient.error_message.should eq 'a'*512
        failed_recipient.failed?.should be true
      end

      it 'failed scope includes failed status ' do
        subject.failed!
        EmailRecipient.failed.should include(subject)
      end

      it 'failed scope does not include canceled status' do
        subject.canceled! :ack
        EmailRecipient.failed.should_not include(subject)
      end

      it 'sent scope includes sent status' do
        subject.sent! :ack
        EmailRecipient.sent.should include(subject)
      end
    end
  end
end
