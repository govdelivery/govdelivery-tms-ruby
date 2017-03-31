# An authenticator for users that handles one time session tokens
class SessionStrategy < Devise::Strategies::Authenticatable
  def valid?
    !request.headers['X-AUTH-TOKEN']
  end

  def authenticate!
    u = OneTimeSessionToken.user_for(params[:token])
    u.nil? ? fail : success!(u)
  end
end
Warden::Strategies.add(:session_strategy, SessionStrategy)
