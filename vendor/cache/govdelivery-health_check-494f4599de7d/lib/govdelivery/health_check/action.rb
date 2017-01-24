# frozen_string_literal: true

module GovDelivery
  module HealthCheck
    class WebAction
      RACK_SESSION = 'rack.session'.freeze

      attr_accessor :router, :context, :env, :block, :type

      def request
        @request ||= ::Rack::Request.new(env)
      end

      def params
        indifferent_hash = Hash.new {|hash,key| hash[key.to_s] if Symbol === key }

        indifferent_hash.merge! request.params
        route_params.each {|k,v| indifferent_hash[k.to_s] = v }

        indifferent_hash
      end

      def route_params
        env[Router::ROUTE_PARAMS]
      end

      def session
        env[RACK_SESSION]
      end

      def content_type(type)
        @type = type
      end

      def initialize(router, context, env, block)
        @router = router
        @context = context
        @env = env
        @block = block
        @@files ||= {}
      end

      def method_missing(name, *args, &block)
        router.send(name, *args, &block)
      end
    end
  end
end
