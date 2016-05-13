FactoryGirl.define do
  factory :message_type do
    before(:create) do |message_type|
      message_type.account ||= create(:account)
    end

    name 'steve'
    name_key 'steve_key'
  end
end
