$prefix_sequence = 1

FactoryGirl.define do
  factory :account do
    name "ACME"
    dcm_account_codes ['ACME']

    before(:create) do |account, evaluator|
      evaluator.build_from_address({from_email: 'hey@dude.test'})
      if(account.sms_vendor && account.sms_vendor.shared?)
        account.sms_prefixes.build({
          prefix: "PREFIX#{$prefix_sequence += 1}"
        })
      end
    end
  end

end
