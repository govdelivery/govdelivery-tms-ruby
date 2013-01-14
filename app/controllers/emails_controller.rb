class EmailsController < ApplicationController
  include FeatureChecker
  before_filter :find_user
  feature :email

  def create
    TmsWorker.perform_async(:email=>params[:email], :account_id=>@account.id)
    render :json=>'{}', :status => :created
  end
end
