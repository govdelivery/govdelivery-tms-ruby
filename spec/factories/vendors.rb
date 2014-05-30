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
    stop_text 'goodbye'
    help_text 'too bad'
    default_response_text "I don't understand"

    # # pretent like a save - optimization
    after(:build) do |vendor,eval|
      vendor.build_help_keyword
      vendor.build_stop_keyword
      vendor.build_start_keyword
      vendor.build_default_keyword
    end
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

  factory :ipaws_vendor, class: IPAWS::Vendor do
    cog_id 1
    user_id 'IPAWSOPEN_1'
    public_password 'aligator'
    private_password '#@)(*$DSKOJFSPO*'
    jks 'JKS'
  end
end
