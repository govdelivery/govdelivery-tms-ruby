FactoryGirl.define do
  factory :sms_message do
    body "Junk 4 U"
  end
  factory :email_message do
    body "Junk 5 U"
    subject 'Junkity-junk junk junk'
    account
  end
end
