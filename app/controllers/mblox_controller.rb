class MbloxController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  respond_to :json

  def report
    Mblox::StatusWorker.perform_async(
      {
        status:    params['status'],
        code:      params['code'],
        ack:       params['batch_id'],
        recipient: params['recipient']
      })
    render text: '', status: 201
  end

  private


end
