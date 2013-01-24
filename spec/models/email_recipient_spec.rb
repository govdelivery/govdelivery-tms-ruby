require 'spec_helper'

describe EmailRecipient do
  subject {
    v = create_email_vendor
    m = EmailMessage.new(:body => 'short body', :subject=>'fuuu')
    a = Account.create(:name => 'account', :email_vendor => v)
    u = User.create(:email => 'admin@example.com', :password => 'retek01!')
    u.account = a
    m.account = a
    r = m.recipients.build
    r.message = m
    r.vendor = v
    r
  }

  its(:email) { should be_nil }
  it { should_not be_valid }
end

