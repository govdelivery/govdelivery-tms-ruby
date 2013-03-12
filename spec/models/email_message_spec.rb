require 'spec_helper'

describe EmailMessage do
  let(:vendor) { create_email_vendor }
  let(:account) { vendor.accounts.create(:name => 'name', :from_address=>create_from_address) }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:email) { user.email_messages.build(
    :body => 'longggg body', 
    :subject => 'specs before tests', 
    :open_tracking_enabled => true, 
    :click_tracking_enabled => true,
    :macros => {
      'macro1' => 'foo', 
      'macro2' => 'bar',
      'first' => 'bazeliefooga'
    }
  ) }
  subject { email }

  context "with nil tracking flags" do
    it 'should interpret them as true' do
      email.open_tracking_enabled = nil
      email.click_tracking_enabled = nil
      email.save!
      email.reload
      email.open_tracking_enabled.should be_true
      email.click_tracking_enabled.should be_true
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

      context 'and sending!' do
        before do
          email.expects(:recipients).returns(mock(:update_all=>true))
          email.sending!('dummy_id')
        end
        it { email.ack.should eq('dummy_id') }
      end

      [:opened, :clicked].each do |type|
        context "with recips who #{type}" do
          before do
            email.create_recipients([:email => 'tyler@dudes.com', :email => 'ben@dudees.com'])
            
            # one dude twice, the other not at all
            recip = email.recipients.reload.first
            recip.send(:"#{type}!", "http://dudes.com/tyler", DateTime.now)
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

end
