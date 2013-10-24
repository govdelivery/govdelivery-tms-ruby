FactoryGirl.define do

  sequence(:short_code, '100000')

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
    from { generate(:short_code) }
    shared false
  end

  factory :shared_sms_vendor, class: SmsVendor, traits: [:vendor] do
    username 'username'
    password 'secret'
    from { generate(:short_code) }
    shared true
  end

  factory :voice_vendor, traits: [:vendor] do
    name 'voice vendor'
    username 'username'
    password 'secret'
    from '+15555555555'
  end
end
