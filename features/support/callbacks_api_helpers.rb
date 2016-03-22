require 'uri'

class CallbacksAPIClient
  attr_accessor :callback_uris
  attr_accessor :callback_domain
  attr_accessor :callback_root

  def callback_types
    [:recipient_status,
     :sms]
  end


  def initialize
    @callback_root = 'http://xact-webhook-callbacks.herokuapp.com/api/v3/'
    uri = URI.parse(callback_root)
    @callback_domain = "#{uri.scheme}://#{uri.host}"
    @callback_uris = []
  end

  def create_callback_uri(type=nil, desc=nil)
    raise 'Must provide callback type' if type.nil?
    raise "Callback Type #{type} not supported " unless callback_types.include?(type)

    conn = faraday(callback_root)

    payload = {}
    payload[:desc] = desc if desc
    resp = conn.post "#{type}/", payload

    raise "Callback Endpoint Creation Failed\n Status: #{resp.status}\n #{resp.body}" unless resp.status == 200

    uri = JSON.parse(resp.body)['url']
    @callback_uris << uri
    uri
  end

  def destroy_callback_uri(uri)
    conn = faraday(callback_root)

    resp = conn.delete uri

    raise "Callback Endpoint Deletion Failed\n Status: #{resp.status}\n #{resp.body}" unless resp.status == 204

    i = @callback_uris.index(uri)
    @callback_uris.delete_at(i) if i

    true
  end

  def destroy_all_callback_uris
    all_callback_endpoints = Array.new(callback_uris)
    all_callback_endpoints.each do |uri|
      destroy_callback_uri(uri)
    end
    true
  end

  def get(uri)
    conn = faraday(callback_root)
    resp = conn.get uri

    raise "Callback Endpoint Get Failed\n Status: #{resp.status}\n #{resp.body}" unless resp.status == 200

    JSON.parse(resp.body)
  end

end
