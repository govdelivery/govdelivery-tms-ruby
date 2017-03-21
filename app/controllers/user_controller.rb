class UserController < ApplicationController
  before_action :find_user

  def login
    one_time_token = current_user.one_time_session_token.value
    "/session/new?token=#{one_time_token}"
  end
end
