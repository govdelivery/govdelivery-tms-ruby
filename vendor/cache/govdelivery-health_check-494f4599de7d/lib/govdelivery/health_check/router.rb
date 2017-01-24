# frozen_string_literal: true
require 'rack'

module GovDelivery
  module HealthCheck
    module Router
      CONTENT_LENGTH = "Content-Length".freeze
      ROUTE_PARAMS = 'rack.route_params'.freeze
      PATH_INFO = 'PATH_INFO'.freeze

      MUTEX = Mutex.new

      class << self
        def included(base)
          base.class_eval do
            extend Router
          end
        end
      end

      attr_accessor :context

      def initialize(args = {})
        @context = deep_dup(self.class.context).merge(args)
        @routes = self.class.routes
        @before_routes = self.class.before_routes
      end

      def route(path, &block)
        routes << WebRoute.new(path, block)
      end

      def before_route(&block)
        MUTEX.synchronize do
          before_routes << block
        end
      end

      def set(name, value)
        MUTEX.synchronize do
          context[name] = value
        end
      end

      def before_routes
        @before_routes ||= []
      end

      def routes
        @routes ||= []
      end

      def context
        @context ||= {}
      end

      def match(env)
        path_info = ::Rack::Utils.unescape env[PATH_INFO]

        # There are servers which send an empty string when requesting the root.
        # These servers should be ashamed of themselves.
        path_info = "/" if path_info == ""

        routes.each do |route|
          if params = route.match(path_info)
            env[ROUTE_PARAMS] = params

            return WebAction.new(is_a?(Router) ? self : self.new, @context, env, route.block)
          end
        end

        nil
      end

      def call(env)
        action = match(env)
        return [404, { "Content-Type" => 'text/plain' }, ["Not Found"]] unless action

        before_routes.each do |block|
          before_action = WebAction.new(self, context, env, block)
          resp = before_action.instance_exec env, &before_action.block
          return resp if resp
        end

        resp = action.instance_exec env, &action.block
        resp[1] = resp[1].dup
        resp[1][CONTENT_LENGTH] = resp[2].inject(0) { |l, p| l + p.bytesize }.to_s
        resp
      end

      def method_missing(name, *args, &block)
        return @context[name] if @context.key? name
        super
      end

      private

      def deep_dup(hsh)
        hash = {}
        hsh.each do |key, value|
          hash[key] = value.dup
        end
        hash
      end
    end

    class WebRoute
      attr_accessor :pattern, :block, :name

      NAMED_SEGMENTS_PATTERN = /\/([^\/]*):([^\.:$\/]+)/.freeze

      def initialize(pattern, block)
        @pattern = pattern
        @block = block
      end

      def matcher
        @matcher ||= compile
      end

      def compile
        if pattern.match(NAMED_SEGMENTS_PATTERN)
          p = pattern.gsub(NAMED_SEGMENTS_PATTERN, '/\1(?<\2>[^$/]+)')

          Regexp.new("\\A#{p}\\Z")
        else
          pattern
        end
      end

      def match(path)
        case matcher
        when String
          {} if path == matcher
        else
          if path_match = path.match(matcher)
            Hash[path_match.names.map(&:to_sym).zip(path_match.captures)]
          end
        end
      end
    end
  end
end
