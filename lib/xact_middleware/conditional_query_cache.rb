module XactMiddleware
  class ConditionalQueryCache < ActiveRecord::QueryCache

    def call(env)
      if env['REQUEST_URI'].match(Rails.configuration.no_db_regex)
        @app.call(env)
      else
        super
      end
    end
  end
end
