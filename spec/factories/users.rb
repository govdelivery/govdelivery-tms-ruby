FactoryGirl.define do

  factory :user do
    association :account, strategy: :build
    sequence(:email) {|n| "user#{n}@example.com"}
    password 'password'
  end

end