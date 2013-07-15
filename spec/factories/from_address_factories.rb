FactoryGirl.define do
  
  factory :from_address do
    sequence(:from_email){|i| "hey#{i}@dude.test" }
  end
end
