class ClicksController < ApplicationController
  before_filter :find_user
  before_filter :set_page, only: [:index]

  def index
    @clicks = clicks_for(params[:email_id], params[:recipient_id]).page(@page)
  end

  def show
    @click = clicks_for(params[:email_id], params[:recipient_id]).find(params[:id])
  end

  private

  def clicks_for(email_id, recipient_id)
    r = current_user.account_email_messages.find(email_id).recipients.find(recipient_id)
    r.email_recipient_clicks
  end
end
