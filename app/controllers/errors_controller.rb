class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!, :authenticate_user_from_token!

  def show
    render status_code.to_s, status: status_code
  end

  protected

  def status_code
    params[:code] || 500
  end
end
