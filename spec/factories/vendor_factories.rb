FactoryGirl.define do

  trait :vendor do
    sequence(:name) {|n| "name#{n}" }
    worker 'LoopbackMessageWorker'
  end

  factory :email_vendor, traits: [:vendor] do
    name 'new name'    
  end

  factory :sms_vendor, traits: [:vendor] do
    username 'username'
    password 'secret'
    from '+15555555555'
    shared false
  end

  factory :shared_sms_vendor, class: SmsVendor, traits: [:vendor] do
    username 'username'
    password 'secret'
    from '+15555555555'
    shared true
  end

  factory :voice_vendor, traits: [:vendor] do
    name 'voice vendor'
    username 'username'
    password 'secret'
    from '+15555555555'
  end
end
