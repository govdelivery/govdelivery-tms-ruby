FactoryGirl.define do
  factory :one_time_session_token do
    association :user
  end
end