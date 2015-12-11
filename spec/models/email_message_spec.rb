require 'rails_helper'

RSpec.shared_examples 'an email message that can be templated' do
  it "nullifies association if email_template is deleted" do
    subject.email_template = email_template
    subject.save!
    email_template.destroy
    subject.reload
    expect(subject.email_template).to be_nil
  end

  it "prefers attributes on the message when set" do
    subject.body                          = 'a new body with [[things]]'
    subject.subject                       = 'a unique subject'
    subject.macros                        = {"things" => 'stuff'}
    subject.open_tracking_enabled         = false
    subject.click_tracking_enabled        = false
    email_template.click_tracking_enabled = !subject.click_tracking_enabled
    email_template.open_tracking_enabled  = !subject.open_tracking_enabled
    subject.email_template                = email_template
    subject.save!
    %w{body subject macros click_tracking_enabled open_tracking_enabled}.each do |field|
      expect(subject.send(field)).to_not eq(email_template.send(field))
    end
  end

  context 'with unspecified attributes' do
    subject { empty_email }
    it "uses attributes from template" do
      email_template.click_tracking_enabled = false
      email_template.open_tracking_enabled  = false
      subject.email_template                = email_template
      subject.save!
      %w{body subject macros click_tracking_enabled open_tracking_enabled}.each do |field|
        expect(subject.send(field)).to eq(email_template.send(field))
      end
    end
  end
end

describe EmailMessage do
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor, name: 'name', link_tracking_parameters: 'pi=3') } # http://www.quickmeme.com/img/b3/b3fe35940097bdc40a6d9f26ad06318741a0df1b982881524423046eb43a70e7.jpg
  let(:from_address) { account.default_from_address }
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
  let(:email_template) { create(:email_template, account: account, user: user, from_address: from_address) }
  let(:email_template_sans_link_params) { create(:email_template, account: account, user: user, from_address: from_address, link_tracking_parameters: nil) }
  let(:body_with_links) { 'longggg body with <a href="http://stuff.com/index.html">some</a> great <a href="https://donkeys.com/store/">links</a>' }
  let(:email_params) {
    {body:                   body_with_links,
     subject:                'specs before tests',
     open_tracking_enabled:  false,
     click_tracking_enabled: true
    }
  }
  let(:email) do
    user.email_messages.build(
      email_params.merge(
        {from_email: account.from_email,
         macros:     {
           'macro1' => 'foo',
           'macro2' => 'bar',
           'first'  => 'bazeliefooga'
         }})
    )
  end
  let(:empty_email) do
    build(:email_message,
          user:                   user,
          body:                   nil,
          subject:                nil,
          from_email:             nil,
          open_tracking_enabled:  nil,
          click_tracking_enabled: nil,
          macros:                 nil
    )
  end
  let(:macroless_email) do
    build(:email_message,
          user:                   user,
          account:                account,
          body:                   'longggg body',
          subject:                'specs before tests',
          from_email:             account.from_email,
          open_tracking_enabled:  true,
          click_tracking_enabled: true,
          macros:                 {}
    )
  end
  let(:templated_email) do
    build(:email_message,
          user:           user,
          account:        account,
          body:           body_with_links,
          email_template: email_template)
  end
  let(:templated_email_sans_link_params) do
    build(:email_message,
          user:           user,
          account:        account,
          body:           'longggg body with <a href="http://stuff.com/index.html">some</a> great <a href="https://donkeys.com/store/">links</a>',
          body:           body_with_links,
          email_template: email_template_sans_link_params)
  end
  subject { email }

  it_should_validate_as_email :reply_to, :errors_to
  it_behaves_like 'an email message that can be templated'

  before do
    Analytics::PublisherWorker.stubs(:perform_async)
  end

  context "built via a user" do
    subject { user.email_messages.build }

    it "should have nil default values on build" do
      [:subject, :body, :from_name, :from_email, :ack, :macros, :open_tracking_enabled, :click_tracking_enabled].each do |attr|
        expect(subject.send(attr)).to be_nil
      end
    end

    it_behaves_like 'an email message that can be templated'
  end

  context "email_template association" do
    it { is_expected.to belong_to :email_template }
    it "can be blank" do
      expect(subject.email_template).to be_blank
    end
  end

  context 'with nil tracking flags' do
    it 'should interpret them as true' do
      email.open_tracking_enabled  = nil
      email.click_tracking_enabled = nil
      email.save!
      email.reload
      expect(email.open_tracking_enabled).to be true
      expect(email.click_tracking_enabled).to be true
    end
  end

  context '#ready!' do
    before do
      email.save!
      email.create_recipients([email: 'tyler@dudes.com'])
      expect(email.status).to eq('new')
    end
    context 'when ready! fails' do
      it 'should raise an ActiveRecord error' do
        email.open_tracking_enabled = nil
        expect { email.ready! }.to raise_error(ActiveRecord::RecordInvalid, /Open tracking enabled is not included in the list/)
        expect(email.status).to eq('new')
      end
    end
    context 'when ready! succeeds' do
      it 'should change the message state' do
        expect { email.ready! }.not_to raise_error
        expect(email.status).to eq('queued')
      end
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
      before do
        email.save!
        templated_email.save!
        templated_email_sans_link_params.save!
      end

      it 'should be able to create recipients' do
        email.create_recipients([email: 'tyler@dudes.com'])
        expect(email.recipients.reload.count).to eq(1)
      end

      it 'should select proper columns for list' do
        result   = user.email_messages.indexed.first
        cols     = [:user_id, :created_at, :status, :subject, :id, :email_template_id]
        not_cols = (EmailMessage.columns.map(&:name).map(&:to_sym) - cols)

        cols.each do |c|
          expect(result.respond_to?(c)).to eq true
        end
        not_cols.each do |c|
          expect(result.respond_to?(c)).to eq false
        end
      end

      context 'and ready!' do
        before do
          email.recipients.create!(email: 'bill@busheyworld.ie')
          templated_email.recipients.create!(email: 'bill@busheyworld.ie')
          templated_email_sans_link_params.recipients.create!(email: 'bill@busheyworld.ie')
        end

        it 'should insert tracking parameters into all links' do
          expect(email.ready!).to be true
          expect(email.body).to_not include '<a href="http://stuff.com/index.html">some</a>'
          expect(email.body).to include '<a href="http://stuff.com/index.html?pi=3">some</a>'
          expect(email.body).to_not include '<a href="https://donkeys.com/store/">links</a>'
          expect(email.body).to include '<a href="https://donkeys.com/store/?pi=3">links</a>'
        end

        it 'should use template tracking parameters if a template is used' do
          expect(templated_email.ready!).to be true
          templated_email.reload
          expect(templated_email.body).to_not include '<a href="http://stuff.com/index.html">some</a>'
          expect(templated_email.body).to_not include '<a href="https://donkeys.com/store/">links</a>'
          templated_email.body.scan(/https?:\/\/[\S]+\?([\S]*?)">/) do |query_params|
            query_params_array = query_params[0].split('&')
            expect(query_params_array).to include 'tracking=param'
            expect(query_params_array).to include 'one=two'
          end
        end

        it 'should use account tracking parameters if a template without tracking parameters is used' do
          expect(templated_email_sans_link_params.ready!).to be true
          templated_email_sans_link_params.reload
          expect(templated_email_sans_link_params.body).to_not include '<a href="http://stuff.com/index.html">some</a>'
          expect(templated_email_sans_link_params.body).to include '<a href="http://stuff.com/index.html?pi=3">some</a>'
          expect(templated_email_sans_link_params.body).to_not include '<a href="https://donkeys.com/store/">links</a>'
          expect(templated_email_sans_link_params.body).to include '<a href="https://donkeys.com/store/?pi=3">links</a>'
        end

        it 'should merge email template macros if they are specified' do
          macro_email = user.email_messages.build(
            email_params.merge(
              {from_email: account.from_email,
               macros:     {
                 'macro1' => 'foo',
                 'macro2' => 'bar',
                 'first'  => 'bazeliefooga'
               }})
          )
          macro_template = create(:email_template, account: account, user: user, from_address: from_address, macros: {'macro1' => 'baz', 'macro3' => 'baz'})
          macro_email.email_template = macro_template
          macro_email.save!
          expect(macro_email.macros).to eq({
            'macro1' => 'foo',
            'macro2' => 'bar',
            'macro3' => 'baz',
            'first'  => 'bazeliefooga'
          })
        end

        it 'should set email template macros if they are specified' do
          macro_email = user.email_messages.build(
            email_params.merge(
              {from_email: account.from_email,
               macros: nil})
          )
          macro_template = create(:email_template, account: account, user: user, from_address: from_address, macros: {'macro1' => 'baz'})
          macro_email.email_template = macro_template
          macro_email.save!
          expect(macro_email.macros).to eq({
            'macro1' => 'baz'
          })
        end

        it 'should use message macros if they are specified and the email template macros are nil' do
          macro_email = user.email_messages.build(
            email_params.merge(
              {from_email: account.from_email,
               macros: {
                'macro1' => 'bar'
              }})
          )
          macro_template = create(:email_template, account: account, user: user, from_address: from_address, macros: nil)
          macro_email.email_template = macro_template
          macro_email.save!
          expect(macro_email.macros).to eq({
            'macro1' => 'bar'
          })
        end

        context '#insert_link_tracking_parameters' do
          let(:body_with_links) {'longggg body with <a href="http://stuff.com/index.html">some</a> great <a href="https://donkeys.com/s\'tore/">links</a>'}

          it 'should use enhanced link parsing in govdelivery-links when asked' do
            Conf.stubs(:use_simple_link_detection).returns(false)
            email.send :insert_link_tracking_parameters
            expect(email.body).to_not include 'longggg body with <a href="http://stuff.com/index.html?pi=3">some</a> great <a href="https://donkey?pi=3\'s.com/store/">links</a>'
            expect(email.body).to include '<a href="https://donkeys.com/s\'tore/?pi=3">links</a>'
          end
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
            email.create_recipients([{email: 'tyler@dudes.com'}, {email: 'ben@dudees.com'}])

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
            email.create_recipients([{email: 'tyler@dudes.com'}, {email: 'ben@dudees.com'}])

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

  context 'FromAddress' do
    let(:template_from_address) do
      account.from_addresses.create(from_email: 'template@sink.govdelivery.com',
                                    reply_to:   'template-reply-to@sink.govdelivery.com',
                                    errors_to:  'template-bounces@sink.govdelivery.com')
    end
    let(:email_template_non_default_from_address) { create(:email_template, account: account, user: user, from_address: template_from_address) }
    let(:other_from_address) do
      account.from_addresses.create(from_email: 'other@sink.govdelivery.com',
                                    reply_to:   'other-reply-to@sink.govdelivery.com',
                                    errors_to:  'other-bounces@sink.govdelivery.com')
    end

    it 'should be the default when not specified' do
      account.default_from_address.update_attributes(
        from_email: 'default@sink.govdelivery.com',
        reply_to:   'default-reply-to@sink.govdelivery.com',
        errors_to:  'default-bounces@sink.govdelivery.com'
      )
      email_message = user.email_messages.build(email_params)
      expect(email_message.valid?).to be true
      expect(email_message.from_email).to eq account.default_from_address.from_email
      expect(email_message.errors_to).to eq account.default_from_address.errors_to
      expect(email_message.reply_to).to eq account.default_from_address.reply_to
    end
    it 'should use from_email when optional FromAddress values are blank' do
      email_message = user.email_messages.build(email_params)
      expect(email_message.valid?).to be true
      expect(email_message.from_email).to eq from_address.from_email
      expect(email_message.errors_to).to eq from_address.from_email
      expect(email_message.reply_to).to eq from_address.from_email
    end
    it 'should use template' do
      email_message = user.email_messages.build(email_params.merge(email_template: email_template_non_default_from_address))
      expect(email_message.valid?).to be true
      expect(email_message.from_email).to eq template_from_address.from_email
      expect(email_message.errors_to).to eq template_from_address.errors_to
      expect(email_message.reply_to).to eq template_from_address.reply_to
    end
    it 'should override template' do
      email_message = user.email_messages.build(email_params.merge(email_template: email_template_non_default_from_address, from_email: other_from_address.from_email))
      expect(email_message.valid?).to be true
      expect(email_message.from_email).to eq other_from_address.from_email
      expect(email_message.errors_to).to eq other_from_address.errors_to
      expect(email_message.reply_to).to eq other_from_address.reply_to
    end
  end
end
