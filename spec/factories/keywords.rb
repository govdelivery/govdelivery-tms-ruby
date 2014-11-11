FactoryGirl.define do

  factory :keyword do
    name { generate(:keyword_name) }

    # always build the account first
    factory :account_keyword do

      before(:create) do |keyword|
        keyword.account ||= create( :account_with_sms )
      end

      factory :custom_keyword, class: Keyword
      # factory :account_stop, class: Keywords::AccountStop
      # factory :account_help, class: Keywords::AccountHelp
      # factory :account_default, class: Keywords::AccountDefault
    end
  end

  # factory :vendor_stop, class: Keywords::VendorStop, traits: [:vendor_keyword, :special]
  # factory :vendor_help, class: Keywords::VendorHelp, traits: [:vendor_keyword, :special]
  # factory :vendor_default, class: Keywords::VendorDefault, traits: [:vendor_keyword, :special]

end
