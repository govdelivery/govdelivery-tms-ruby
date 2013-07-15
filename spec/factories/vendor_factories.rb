FactoryGirl.define do

  trait :vendor do
    name 'name'
    worker 'LoopbackMessageWorker'
  end

  factory :email_vendor, traits: [:vendor] do
    name 'new name'    
  end

  factory :sms_vendor, traits: [:vendor] do
    username 'username'
    password 'secret'
    from '+15555555555'
  end

  factory :voice_vendor, traits: [:vendor] do
    name 'voice vendor'
    username 'username'
    password 'secret'
    from '+15555555555'
  end
end
