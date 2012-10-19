class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods 
  
  before_filter :login_from_basic_auth

  protected
  def login_from_basic_auth
    authenticate_or_request_with_http_basic do |username, password| 
      session[:current_user_id] = User.authenticate(username, password).try(:id) 
    end unless User.find_by_id(session[:current_user_id])
    session[:current_user_id]
  end
end
