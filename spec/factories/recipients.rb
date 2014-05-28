FactoryGirl.define do
  factory :sms_recipient do
    phone "6123089081"
  end
  factory :email_recipient do
    email "schwoop@sink.govdelivery.com"
  end
end
