class SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token, if: :json_request?
  skip_before_action :verify_signed_out_user, only: :destroy
  prepend_before_action :allow_params_authentication!, only: :create

  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in_resource(resource_name, resource)
  end

  # DELETE /resource/sign_out
  def destroy
    if current_user
      sign_out_resource(resource_name)
      redirect_to root_path
    else
      return render :json => {:success => false}
    end
  end

  def failure
    return render :json => {:success => false, :errors => ["Login failed."]}
  end

  protected

  def sign_in_resource(resource_name, resource=nil)
    sign_in(resource) unless warden.user(resource_name) == current_user
    redirect_to root_path
  end

  def sign_out_resource(resource_name)
    sign_out(warden.user(resource_name))
  end

  def json_request?
    request.format.json?
  end

end
