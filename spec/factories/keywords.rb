FactoryGirl.define do

  factory :keyword do
    name { generate(:keyword_name) }

    # always build the account first
    factory :account_keyword do

      before(:create) do |keyword|
        keyword.account = create( :account_with_sms )
      end

      factory :custom_keyword, class: Keyword do

      end

      factory :account_stop, class: Keywords::AccountHelp do
        initialize_with do
          create(:account_with_sms).stop_keyword
        end
      end

      factory :account_help, class: Keywords::AccountHelp do
        initialize_with do
          create(:account_with_sms).help_keyword
        end
      end

      factory :account_default, class: Keywords::AccountHelp do
        initialize_with do
          create(:account_with_sms).default_keyword
        end
      end
    end
  end

  trait :special do
    skip_create
  end

  # this is not a factory because vendor's cannot have keywords
  # except for the special ones
  trait :vendor_keyword do
    vendor factory: :sms_vendor
  end

  factory :vendor_stop, class: Keywords::VendorStop, traits: [:vendor_keyword, :special]
  factory :vendor_help, class: Keywords::VendorHelp, traits: [:vendor_keyword, :special]
  factory :vendor_default, class: Keywords::VendorDefault, traits: [:vendor_keyword, :special]

end
