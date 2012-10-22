class HttpAuthenticatableApi < Devise::Strategies::HttpAuthenticatable
  def valid?
    not request_format.html? or super
  end
  def http_authentication
    super or ''
  end
end
Warden::Strategies.add(:http_auth_api, HttpAuthenticatableApi)