FactoryGirl.define do
  factory :sms_prefix do
    account
    sequence(:prefix) { |i| "PREFIX#{i}"}
    to_create do |instance|
      instance.valid? # this needs to run I guess
      instance.save!
    end
  end
end
