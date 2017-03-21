# An authenticator for users that handles one time session tokens
class OneTimeSessionAuthenticationApi < Devise::Strategies::Authenticatable
  def valid?
    # double check that request.url is what we really need here
    !request.headers['X-AUTH-TOKEN'] && request.url
  end

  def authenticate!
    # looking for the query params value in url ie: /session/new?token=1234
    u = OneTimeSessionToken.user_for(params[:token])
    u.nil ? fail! : success!(u)
  end
end
Warden::Strategies.add(:one_time_session_auth_api, OneTimeSessionAuthenticationApi)
