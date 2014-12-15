FactoryGirl.define do

  factory :command_parameters , class: CommandParameters do
    skip_create

    factory :forward_command_parameters do
      command_type CommandType[:forward]
      url 'http://somewhere.out.there'
      http_method 'GET'
    end

    factory :subscribe_command_parameters do
      dcm_account_code 'ACME'
      dcm_topic_codes ["ACME","VANDELAY"]
      command_type :dcm_subscribe
    end

    factory :unsubscribe_command_parameters do
      command_type :dcm_subscribe
      dcm_account_codes ["ACME","VANDELAY"]
    end
  end
end
