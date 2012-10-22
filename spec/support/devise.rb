# rspec integration for devise.  
# see https://github.com/plataformatec/devise
#
# sign_in :user, @user   # sign_in(scope, resource)
# sign_in @user          # sign_in(resource)
# 
# sign_out :user         # sign_out(scope)
# sign_out @user         # sign_out(resource)
#
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end