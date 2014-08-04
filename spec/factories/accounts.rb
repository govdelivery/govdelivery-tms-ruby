FactoryGirl.define do

  factory :account do
    sequence(:name) {|n| "ACME_#{n}" }
    dcm_account_codes ['ACME']

    before(:create) do |account, evaluator|
      evaluator.from_addresses.build({from_email: 'hey@dude.test', is_default: true})
    end

    trait :shared do
      sms_vendor factory: :shared_sms_vendor

    end

    factory :account_with_sms do
      sms_vendor factory: :sms_vendor

      ignore do
        prefix 'abc'
      end

      # a prefix must be created first
      before(:create) do |account,evaluator|
        if evaluator.prefix.present?
          sms_prefix = build(:sms_prefix,
                              prefix: evaluator.prefix,
                              sms_vendor: account.sms_vendor)
          sms_prefix.save!
          account.sms_prefixes << sms_prefix
        end

      end
    end
  end
end
