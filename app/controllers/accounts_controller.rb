class AccountsController < ApplicationController
  before_action lambda { |_c|
    render(json:   {error: 'forbidden'},
           status: :forbidden) unless current_user.admin?
  }
  before_action :find_account, only: [:show, :update, :destroy]
  before_action :wrap_accounts_parameters

  def index
    @accounts = Account.all
  end

  def create
    @account = Account.new(params[:account])
    if params[:from_address]
      @account.from_addresses.build(params[:from_address].merge!(is_default: true))
    end
    if !@account.voice_vendor.nil? && params[:from_number]
      @account.from_numbers.build(params[:from_number].merge!(is_default: true))
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

  def wrap_accounts_parameters
    if ['application/json', 'application/x-www-form-urlencoded'].include?(request.format)
      wrapper_params = {
        account: [
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
          :default_response_text,
          :link_tracking_parameters
        ],
        from_address: [
          :from_email,
          :reply_to,
          :errors_to],
        from_number: [
          :phone_number
        ]
      }

      wrapper_params.each do |wrapper_name, nested_params|
        if nested_params.any? { |p| params.include?(p)}
          params[wrapper_name] = {}
          nested_params.each do |p|
            params[wrapper_name][p] = params[p] if params.include?(p)
          end
        end
      end
    end
  end
end
