FactoryGirl.define do
  factory :inbound_message do
    vendor factory: :sms_vendor
    keyword factory: :custom_keyword
    keyword_response { |i| i.keyword.response_text }
    from { '5555555555' }
    to { '5555555555' }
    body { 'something anything' }
    command_status :no_action

    factory :inbound_stop_request do
    end
  end
end
