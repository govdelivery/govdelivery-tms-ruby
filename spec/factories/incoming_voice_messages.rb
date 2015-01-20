FactoryGirl.define do

  factory :incoming_voice_message do
    from_number factory: :from_number
    expires_in { 300 }
    play_url { 'http://www.wwww.www/com.com' }
    say_text { |i| "message #{i}" }
  end
end
