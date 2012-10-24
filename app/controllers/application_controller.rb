class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json
  self.responder = RablResponder

  before_filter :authenticate_user!

  def find_user
    if user_signed_in?
      @account = current_user.account
      @vendor = @account.vendor
    end
  end
end
