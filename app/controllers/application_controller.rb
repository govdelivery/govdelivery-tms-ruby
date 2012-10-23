class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json
  self.responder = RablResponder

  before_filter :authenticate_user!
end
