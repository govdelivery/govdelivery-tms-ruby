class UserController < ApplicationController
  before_action :find_user

  def login
    @login = {}
    one_time_token = current_user.one_time_session_token.value
    @login[:url] = "/session/new?token=#{one_time_token}"
    respond_with(@login)
  end
end
