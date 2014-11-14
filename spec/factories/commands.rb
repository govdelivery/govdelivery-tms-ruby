FactoryGirl.define do

  sequence(:command_name){ |i| "command#{i}" }

  factory :command do
    name { generate(:command_name) }

    factory :dcm_subscribe_command do
      command_type 'dcm_subscribe'
      params factory: :subscribe_command_parameters
    end

    factory :dcm_unsubscribe_command do
      command_type 'dcm_unsubscribe'
      params factory: :unsubscribe_command_parameters
    end

    factory :forward_command do
      command_type 'forward'
      params factory: :forward_command_parameters
    end
  end
end
