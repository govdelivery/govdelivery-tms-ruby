FactoryGirl.define do
  factory :command_action do
    inbound_message {InboundMessage.new}
  end
end
