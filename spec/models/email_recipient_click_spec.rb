require 'rails_helper'

describe EmailRecipientClick do
  let(:vendor) { create(:email_vendor) }
  let(:account) { create(:account, email_vendor: vendor) }

  let(:email_message) { 
    EmailMessage.new(:body => 'short body', :subject => 'fuuu').tap do |em|
      em.account=account
      em.save!
    end
  }
  
  let(:email_recipient) { 
    email_message.recipients.build(email: 'ortega_jets@evotest.govdelivery.com').tap do |r|
      r.save!
    end
  }

  subject { 
    EmailRecipientClick.new.tap do |erc|
      erc.email_message = email_message
      erc.email_recipient = email_recipient
      erc.email = email_recipient.email
      erc.url = 'http://dontclickonthis.com/very_bad_stuff.html'
      erc.clicked_at = DateTime.now
    end
  }

  it { is_expected.to be_valid }
  
  [:email_message, :email_recipient, :url, :email, :clicked_at].each do |attr|
    context "when #{attr} is nil" do
      before do
        subject.send("#{attr}=", nil)
      end
      it { is_expected.to be_invalid }
    end
  end

  it "should select proper columns for list" do
    subject.save!
    result = email_recipient.email_recipient_clicks.indexed.first
    cols     = [:email_recipient_id, :email_message_id, :clicked_at, :id, :url]
    not_cols = (EmailRecipientClick.columns.map(&:name).map(&:to_sym) - cols)

    cols.each do |c|
      assert result.send(c)
    end
    not_cols.each do |c|
      expect { result.send(c) }.to raise_error
    end
  end
end
