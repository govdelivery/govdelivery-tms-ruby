FactoryGirl.define do
  sequence(:short_code, '100000')

  trait :vendor do
    sequence(:name) { |n| "name#{n}"}
    worker 'LoopbackMessageWorker'
  end

  factory :email_vendor, traits: [:vendor] do
  end

  factory :sms_vendor, traits: [:vendor] do
    username 'username'
    password 'secret'
    from {generate(:short_code)}
  end

  factory :voice_vendor, traits: [:vendor] do
    username 'username'
    password 'secret'
    worker 'TwilioVoiceWorker'
  end

  factory :ipaws_vendor, class: IPAWS::Vendor do
    cog_id 1
    user_id 'IPAWSOPEN_1'
    public_password 'aligator'
    private_password '#@)(*$DSKOJFSPO*'
    jks 'JKS'
  end
end
