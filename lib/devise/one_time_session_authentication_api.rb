# An authenticator for users that handles one time session tokens
class OneTimeSessionAuthenticationApi < Devise::Strategies::Authenticatable
  def valid?
    !request.headers['X-AUTH-TOKEN'] && request.path == 'session'
  end

  def authenticate!
    u = OneTimeSessionToken.user_for(params[:token])
    u.nil ? fail! : success!(u)
  end
end
Warden::Strategies.add(:one_time_session_auth_api, OneTimeSessionAuthenticationApi)
