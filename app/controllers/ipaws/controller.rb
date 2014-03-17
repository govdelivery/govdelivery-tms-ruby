module IPAWS
  class Controller < ApplicationController

    before_filter :find_user # sets @account
    before_filter :ensure_account_has_ipaws_enabled

    protected

    def ipaws_client
      IPAWSClient.new(120082, "IPAWSOPEN_120082", "config/IPAWSOPEN_120082.jks", "w0rk#8980", "2670soa#wRn")
    end

    private

    def ensure_account_has_ipaws_enabled
      unless @account.ipaws_enabled?
        render json: { errors: ["IPAWS is not enabled on your account.  Please contact GovDelivery for further assistance."] }, status: :forbidden
      end
    end

  end
end