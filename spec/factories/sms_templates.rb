FactoryGirl.define do
  factory :sms_template do
    body '[TEMPLATE]'
    user
    account
  end
end
