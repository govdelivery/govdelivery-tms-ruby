class MbloxController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  respond_to :json

  def report
    Mblox::StatusWorker.perform_async(params.slice(:status, :code, :batch_id, :recipient))
    render text: '', status: 201
  end

end
