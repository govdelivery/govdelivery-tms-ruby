FactoryGirl.define do

  sequence(:command_name){ |i| "command#{i}" }

  factory :command do
    account factory: :account_with_sms, dcm_account_codes: ['cia']
    name { generate(:command_name) }

    factory :dcm_subscribe_command do
      command_type 'dcm_subscribe'
      params factory: :subscribe_command_parameters
    end

    factory :dcm_unsubscribe_command do
      command_type 'dcm_unsubscribe'
      params factory: :unsubscribe_command_parameters
    end
  end
end
