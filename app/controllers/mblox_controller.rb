class MbloxController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  respond_to :json

  def report
    recipient.send(transition, recipient.ack) if transition
    render text: '', status: 201
  end

  private

  def recipient
    @recipient ||= SmsRecipient.where(ack: params['batch_id'], formatted_phone: params['recipient']).first || raise(ActiveRecord::RecordNotFound)
  end

  def transition
    secondary_status = params['code']
    case params['status']
    when "Queued", "Dispatched"
      nil # noop
    when "Aborted"
      [402, 405, 407].include?(secondary_status) ? recipient.retry! : :canceled!
    when "Expired"
      recipient.retry! && nil
    when "Delivered"
      :sent!
    when "Failed", "Rejected"
      :failed!
    when "Unknown"
      :inconclusive!
    else
      raise StandardError.new("Invalid delivery state")
    end
  end
end
