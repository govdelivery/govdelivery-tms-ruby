require 'rails_helper'

describe EmailMessage do
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor, name: 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:email) { user.email_messages.build(
    :body => 'longggg body',
    :subject => 'specs before tests',
    :from_email => account.from_email,
    :open_tracking_enabled => true,
    :click_tracking_enabled => true,
    :macros => {
      'macro1' => 'foo',
      'macro2' => 'bar',
      'first' => 'bazeliefooga'
    }
  ) }
  subject { email }

  it_should_validate_as_email :reply_to, :errors_to

  context "with a from_email that is not allowed" do
    before do
      Account.any_instance.stubs(:from_email_allowed?).returns(false)
    end
    it 'should not be valid' do
      email.should be_invalid
      email.errors.get(:from_email).should_not be_empty
    end
  end

  context "with nil tracking flags" do
    it 'should interpret them as true' do
      email.open_tracking_enabled = nil
      email.click_tracking_enabled = nil
      email.save!
      email.reload
      email.open_tracking_enabled.should be true
      email.click_tracking_enabled.should be true
    end
  end
  context "with all attributes" do
    it { should be_valid }
    it 'should set the account' do
      account.should_not be_nil
    end
    it 'should have a record designator for odm' do
      subject.odm_record_designator.should eq('email::recipient_id::first::macro1::macro2')
      subject.macros = {}
      subject.odm_record_designator.should eq('email::recipient_id')
    end
    context 'and saved' do
      before { email.save! }

      it 'should be able to create recipients' do
        rcpt = email.create_recipients([:email => 'tyler@dudes.com'])
        email.recipients.reload.count.should eq(1)
      end

      it "should select proper columns for list" do
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

      context 'and sending!' do
        before do
          email.recipients.create!(email: 'bill@busheyworld.ie')
        end
        it 'should send and set ack' do
          email.ready!.should be true
          email.recipients.first.sending?.should be true
          email.sending!(nil, 'dummy_id').should be true
          email.ack.should eq('dummy_id')
        end

        it 'should skip queued send and set ack' do
          email.sending!(nil, 'dummy_id').should be true
          email.ack.should eq('dummy_id')
        end
      end

      # recipient filters
      [:opened, :clicked, :failed, :sent].each do |type|
        context "with recips who #{type}" do
          before do
            email.create_recipients([:email => 'tyler@dudes.com', :email => 'ben@dudees.com'])

            # one dude twice, the other not at all
            recip = email.recipients.reload.first
            recip.send(:"#{type}!", "http://dudes.com/tyler", DateTime.now)
          end
          it { email.send(:"recipients_who_#{type}").count.should == 1 }
        end
      end
    end
  end

  [:subject, :body].each do |field|
    context "without #{field}" do
      it 'should not be valid' do
        email.send("#{field}=", nil)
        should_not be_valid
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
        email.account.expects(field).returns("return")
        email.send(field).should eq("return")
      end
      it 'should be local from_email when nil and account default is nil' do
        email.send("#{field}=", nil)
        email.from_email = "from_email"
        email.account.expects(field).returns(nil)
        email.send(field).should eq("from_email")
      end
    end
    context "#{field}" do
      it 'should use local value' do
        email.send("#{field}=", 'local')
        email.account.expects(field).never
        email.send(field).should eq("local")
      end
    end
  end
end
