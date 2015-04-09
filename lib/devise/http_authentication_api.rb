# An authenticator using HTTP Basic that does not
# redirect
class HttpAuthenticatableApi < Devise::Strategies::HttpAuthenticatable
  def valid?
    !request_format.html? || super
  end

  def http_authentication
    super || ''
  end
end
Warden::Strategies.add(:http_auth_api, HttpAuthenticatableApi)
