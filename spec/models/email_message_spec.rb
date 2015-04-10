require 'rails_helper'

describe EmailMessage do
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor, name: 'name', link_tracking_parameters: 'pi=3') }    # http://www.quickmeme.com/img/b3/b3fe35940097bdc40a6d9f26ad06318741a0df1b982881524423046eb43a70e7.jpg
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
  let(:email) do
    build(:email_message,
          user: user,
          body: 'longggg body with <a href="http://stuff.com/index.html">some</a> great <a href="https://donkeys.com/store/">links</a>',
          subject: 'specs before tests',
          from_email: account.from_email,
          open_tracking_enabled: true,
          click_tracking_enabled: true,
          macros: {
            'macro1' => 'foo',
            'macro2' => 'bar',
            'first' => 'bazeliefooga'
          }
         )
  end
  let(:macroless_email) do
    build(:email_message,
          user: user,
          body: 'longggg body',
          subject: 'specs before tests',
          from_email: account.from_email,
          open_tracking_enabled: true,
          click_tracking_enabled: true,
          macros: {}
         )
  end
  subject { email }

  it_should_validate_as_email :reply_to, :errors_to

  context 'with a from_email that is not allowed' do
    before do
      Account.any_instance.stubs(:from_email_allowed?).returns(false)
    end
    it 'should not be valid' do
      expect(email).to be_invalid
      expect(email.errors.get(:from_email)).not_to be_empty
    end
  end

  context 'with nil tracking flags' do
    it 'should interpret them as true' do
      email.open_tracking_enabled = nil
      email.click_tracking_enabled = nil
      email.save!
      email.reload
      expect(email.open_tracking_enabled).to be true
      expect(email.click_tracking_enabled).to be true
    end
  end
  context 'with all attributes' do
    it { is_expected.to be_valid }
    it 'should set the account' do
      expect(account).not_to be_nil
    end
    it 'should have a record designator for odm' do
      expect(subject.odm_record_designator).to eq('email::recipient_id::x_tms_recipient::first::macro1::macro2')
      expect(macroless_email.odm_record_designator).to eq('email::recipient_id::x_tms_recipient')
    end
    context 'and saved' do
      before { email.save! }

      it 'should be able to create recipients' do
        email.create_recipients([email: 'tyler@dudes.com'])
        expect(email.recipients.reload.count).to eq(1)
      end

      it 'should select proper columns for list' do
        result = user.email_messages.indexed.first
        cols     = [:user_id, :created_at, :status, :subject, :id]
        not_cols = (EmailMessage.columns.map(&:name).map(&:to_sym) - cols)

        cols.each do |c|
          assert result.send(c)
        end
        not_cols.each do |c|
          expect { result.send(c) }.to raise_error
        end
      end

      context 'and ready!' do
        before do
          email.recipients.create!(email: 'bill@busheyworld.ie')
        end

        it 'should insert tracking parameters into all links' do
          expect(email.ready!).to be true
          expect(email.body).to_not include '<a href="http://stuff.com/index.html">some</a>'
          expect(email.body).to include '<a href="http://stuff.com/index.html?pi=3">some</a>'
          expect(email.body).to_not include '<a href="https://donkeys.com/store/">links</a>'
          expect(email.body).to include '<a href="https://donkeys.com/store/?pi=3">links</a>'
        end
      end

      context 'and sending!' do
        before do
          email.recipients.create!(email: 'bill@busheyworld.ie')
        end
        it 'should send and set ack' do
          expect(email.ready!).to be true
          expect(email.sending!(nil, 'dummy_id')).to be true
          expect(email.recipients.first.sending?).to be true
          expect(email.reload.ack).to eq('dummy_id')
        end

        it 'should not be able to skip queued' do
          expect { email.sending!(nil, 'dummy_id') }.to raise_error(AASM::InvalidTransition)
        end

        context 'and completed! without a message' do
          it 'should not set the macros attribute' do
            expect(email.has_attribute?(:macros)).to be true
            expect(email.ready!).to be true
            expect(email.sending!(nil, 'dummy_id')).to be true
            expect(email.recipients.first.sent!('ack', nil, nil)).to be true

            message = EmailMessage.without_message.find(email.id)
            expect(message.has_attribute?(:macros)).to be false
            expect(message.complete!).to be true
            expect(message.completed_at).to_not be_nil
          end
        end
      end

      [:opened, :clicked].each do |type|
        context "with recips who #{type}" do
          before do
            email.create_recipients([{ email: 'tyler@dudes.com' }, { email: 'ben@dudees.com' }])

            # one dude twice, the other not at all
            recip = email.recipients.reload.first
            recip.send(:"#{type}!", 'http://dudes.com/tyler', Time.now)
          end
          it { expect(email.send(:"recipients_who_#{type}").count).to eq(1) }
        end
      end

      # recipient filters
      [:failed, :sent].each do |type|
        context "with recips who #{type}" do
          before do
            email.create_recipients([{ email: 'tyler@dudes.com' }, { email: 'ben@dudees.com' }])

            # one dude twice, the other not at all
            recip = email.recipients.reload.first
            recip.send(:"#{type}!", 'email_ack', nil, nil)
          end
          it { expect(email.send(:"recipients_who_#{type}").count).to eq(1) }
        end
      end
    end
  end

  [:subject, :body].each do |field|
    context "without #{field}" do
      it 'should not be valid' do
        email.send("#{field}=", nil)
        is_expected.not_to be_valid
      end
    end
  end

  [:errors_to, :reply_to].each do |field|
    before do
      email.account = account
    end
    context "#{field} default" do
      it 'should be account default when nil' do
        email.send("#{field}=", nil)
        email.account.expects(field).returns('return')
        expect(email.send(field)).to eq('return')
      end
      it 'should be local from_email when nil and account default is nil' do
        email.send("#{field}=", nil)
        email.from_email = 'from_email'
        email.account.expects(field).returns(nil)
        expect(email.send(field)).to eq('from_email')
      end
    end
    context "#{field}" do
      it 'should use local value' do
        email.send("#{field}=", 'local')
        email.account.expects(field).never
        expect(email.send(field)).to eq('local')
      end
    end
  end
end
