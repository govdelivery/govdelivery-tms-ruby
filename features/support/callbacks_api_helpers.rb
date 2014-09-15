require 'faraday'

class Callbacks_API_Client
    attr_accessor :callback_uris

    CALLBACK_ROOT = 'http://xact-webhook-callbacks.herokuapp.com/api/v2/'

    def initialize
        @callback_uris = []
    end

    def create_callback_endpoint(desc=nil)

        conn = get_a_faraday

        payload = {}
        payload[:desc] = desc if desc
        resp = conn.post '', payload

        raise "Callback Endpoint Creation Failed\n Status: #{resp.status}\n #{resp.body}" unless resp.status == 200

        uri = JSON.parse(resp.body)['url']
        @callback_uris << uri
        @callback_uris.push
        uri
    end

    def destroy_callback_endpoint(uri)
        conn = get_a_faraday

        resp = conn.delete uri

        raise "Callback Endpoint Deletion Failed\n Status: #{resp.status}\n #{resp.body}" unless resp.status == 204

        i = @callback_uris.index(uri)
        @callback_uris.delete_at(i) if i

        return true
    end

    def destroy_all_callback_endpoints()
        all_callback_endpoints = Array.new(self.callback_uris)
        for uri in all_callback_endpoints
            destroy_callback_endpoint(uri)
        end
        return true
    end

    private
        def get_a_faraday
            Faraday.new(:url => CALLBACK_ROOT) do |faraday|
                faraday.request     :url_encoded
                faraday.response    :logger
                faraday.adapter     Faraday.default_adapter
            end
        end
end