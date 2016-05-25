module XactMiddleware
  class ConditionalQueryCache < ActiveRecord::QueryCache

    def call(env)
      if env['REQUEST_URI'].match(Rails.configuration.skip_url_regex)
        super
      else
        @app.call(env)
      end
    end
  end
end
