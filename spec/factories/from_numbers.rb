FactoryGirl.define do
  
  trait :voice_sequence do
    sequence(:from_number){|i| "888555123{i}" }
  end

  factory :default_from_number, class: FromNumber, traits: [:voice_sequence] do
    is_default true
  end

  factory :from_number, traits: [:voice_sequence] do
    is_default false
  end
end

