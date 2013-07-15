require 'spec_helper'

describe EmailRecipientOpen do
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
    EmailRecipientOpen.new.tap do |ero|
      ero.email_message = email_message
      ero.email_recipient = email_recipient
      ero.email = email_recipient.email
      ero.event_ip = '1.2.3.4'
      ero.opened_at = DateTime.now
    end
  }

  it { should be_valid }
  
  [:email_message, :email_recipient, :event_ip, :email, :opened_at].each do |attr|
    context "when #{attr} is nil" do
      before do
        subject.send("#{attr}=", nil)
      end
      it { should be_invalid }
    end
  end
end
