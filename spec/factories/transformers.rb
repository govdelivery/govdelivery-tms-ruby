FactoryGirl.define do
  factory :transformer do
    content_type "application/json"
    transformer_class "base"
    account
  end
end
