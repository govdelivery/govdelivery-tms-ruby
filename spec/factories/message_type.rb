FactoryGirl.define do
  factory :message_type do
    before(:create) do |message_type|
      message_type.account ||= create(:account)
    end

    label 'steve'
    code 'steve_key'
  end
end
