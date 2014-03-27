class EmailStatsController < ApplicationController
  before_filter :find_user
  before_filter :set_page, only: [:index]

  def index
    r = safe_get_recipient(current_user, params[:email_id], params[:recipient_id])
    @events = events_for(stat_type, r).page(@page)
  end

  def show
    r = safe_get_recipient(current_user, params[:email_id], params[:recipient_id])
    @event = events_for(stat_type, r).find(params[:id])
  end

  private

  # get the recipient if the user has permission
  def safe_get_recipient(user, email_id, recipient_id)
    user.account_email_messages.find(email_id).recipients.find(recipient_id)
  end

  def events_for(type, recipient_scope)
    recipient_scope.send(:"email_recipient_#{type}s").indexed
  end
end
