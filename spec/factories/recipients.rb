FactoryGirl.define do
  factory :sms_recipient do
    phone "6123089081"
  end

  factory :email_recipient do
    email "schwoop@sink.govdelivery.com"

    factory :email_recipient_clicked do
      after(:create) do |recipient, evaluator|
        recipient.clicks.create!
      end
    end
  end

  factory :voice_recipient do
    phone "6514888888"
  end
end
