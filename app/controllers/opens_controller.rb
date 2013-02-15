class OpensController < ApplicationController
  before_filter :find_user
  before_filter :set_page, only: [:index]

  def index
    @opens = opens_for(params[:email_id], params[:recipient_id]).page(@page)
  end

  def show
    @open = opens_for(params[:email_id], params[:recipient_id]).find(params[:id])
  end

  private

  def opens_for(email_id, recipient_id)
    r = current_user.account_email_messages.find(email_id).recipients.find(recipient_id)
    r.email_recipient_opens
  end
end
