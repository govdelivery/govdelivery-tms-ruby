class EmailsController < ApplicationController
  before_filter :find_user

  def create
    TmsWorker.perform_async(:email=>params[:email], :account_id=>@account.id)
    render :json=>'{}', :status => :created
  end
end
