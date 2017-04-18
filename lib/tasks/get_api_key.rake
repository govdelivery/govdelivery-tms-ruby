namespace :helper do
  task api_key: :environment do
    username = User.first.email
    token = User.first.authentication_tokens.first.token
    puts "User: #{username} has Token: #{token}"
  end
end