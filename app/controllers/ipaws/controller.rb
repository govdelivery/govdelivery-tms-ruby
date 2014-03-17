module IPAWS
  class Controller < ApplicationController

    before_filter :find_user # sets @account
    before_filter :ensure_account_has_ipaws_enabled!

    class InvalidIPAWSCredentials < StandardError; end

    rescue_from InvalidIPAWSCredentials, with: :render_ipaws_error

    protected

    def ipaws_client
      # Builds an IPAWS Client object using the credentials provided in the params.
      # If any credentials are missing from the params hash, the error is rendered in JSON as an HTTP 400 response.
      # The JKS file is Base-64 decoded and stored in a temp file because the IPAWSClient requires a path to the file.
      ensure_ipaws_param! :ipaws_user_id
      ensure_ipaws_param! :ipaws_cog_id
      ensure_ipaws_param! :ipaws_jks_base64
      ensure_ipaws_param! :ipaws_public_password
      ensure_ipaws_param! :ipaws_private_password
      jks_tempfile = Tempfile.new('ipaws_jks')
      jks_tempfile.write(Base64.decode64(params[:ipaws_jks_base64]))
      IPAWSClient.new(
        params[:ipaws_user_id].to_i,
        params[:ipaws_cog_id],
        jks_tempfile.path,
        params[:ipaws_public_password],
        params[:ipaws_private_password]
      )
    ensure
      if jks_tempfile
        jks_tempfile.close 
        jks_tempfile.unlink
      end
    end

    private

    def ensure_account_has_ipaws_enabled!
      unless @account.ipaws_enabled?
        render json: { errors: ["IPAWS is not enabled on your account.  Please contact GovDelivery for further assistance."] }, status: :forbidden
      end
    end

    def ensure_ipaws_param!(param)
      raise InvalidIPAWSCredentials.new("Missing required IPAWS parameter: #{param}") if params[param].blank?
    end

    def render_ipaws_error(error)
      render json: { errors: [error.message] }, status: 400
    end

  end
end