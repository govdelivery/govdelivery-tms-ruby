FactoryGirl.define do
  trait :email_sequence do
    sequence(:from_email) { |i| "hey#{i}@dude.test"}
  end

  factory :default_from_address, class: FromAddress, traits: [:email_sequence] do
    is_default true
  end

  factory :from_address, traits: [:email_sequence] do
    is_default false
  end
end
