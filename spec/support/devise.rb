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

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end