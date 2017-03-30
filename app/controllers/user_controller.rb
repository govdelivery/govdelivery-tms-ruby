class UserController < ApplicationController
  before_action :find_user

  def login
    @login = {}
    @login[:url] = user_session_path(token: current_user.one_time_session_token.value)
    respond_with(@login)
  end
end
