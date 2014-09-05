class AccountsController < ApplicationController

  before_filter ->(c) { render(json:   {error: "Something went wrong parsing your request JSON"},
                               status: :forbidden) and return false unless current_user.admin? }
  before_filter :find_account, only: [:show, :update, :destroy]

  wrap_parameters :message,
    include: [
               :name,
               :created_at,
               :updated_at,
               :stop_handler_id,
               :voice_vendor_id,
               :email_vendor_id,
               :sms_vendor_id,
               :ipaws_vendor_id,
               :dcm_account_codes,
               :help_text,
               :stop_text,
               :default_response_text
             ], format: :json

  wrap_parameters :from_address,
                  include: [:from_email,
                            :reply_to,
                            :errors_to],
                  format:  :json

  def index
    @accounts = Account.all
  end

  def create
    @account = Account.new(params[:account])
    if params[:from_address]
      @account.from_addresses.build(params[:from_address].merge!(is_default: true))
    end
    @account.save!
    respond_with(@account)
  end

  def show
    respond_with(@account)
  end

  def update
    @account.update_attributes!(params[:account])
    respond_with(@account)
  end

  def destroy
    @account.destroy
    render nothing: true, status: 204
  end

  protected

  def account_params
  end

  def find_account
    @account = Account.find(params[:id])
  end


end