FactoryGirl.define do
  
  factory :account do
    name "ACME"
    dcm_account_codes ['ACME']

    before(:create) do |account, evaluator|
      evaluator.build_from_address({from_email: 'hey@dude.test'})
      # evaluator.save!
    end
  end

end
