class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json
  self.responder = RablResponder

  before_filter :authenticate_user!
  before_filter :set_default_format


  def set_default_format
    request.format = :json unless params[:format]
  end

  def find_user
    if user_signed_in?
      @account = current_user.account
      @vendor = @account.vendor
    end
  end
end
