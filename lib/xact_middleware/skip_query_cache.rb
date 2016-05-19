module XactMiddleware
  class SkipQueryCache
    def initialize(app)
      @app = app
    end

    def call(env)
      env = ActiveRecord::QueryCache.new(@app).call(env) unless env['REQUEST_URI'].match(Rails.configuration.skip_url_regex)
      @app.call(env)
    end
  end
end
