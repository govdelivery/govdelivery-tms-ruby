FactoryGirl.define do

  factory :keyword do
    name { generate(:keyword_name) }

    # always build the account first
    factory :account_keyword do

      before(:create) do |keyword|
        keyword.account ||= create( :account_with_sms )
      end

      factory :custom_keyword, class: Keyword
    end
  end
end
