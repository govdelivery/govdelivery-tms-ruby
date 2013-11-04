module Workers
  module Base
    def self.included(base)
      base.send(:include, Sidekiq::Worker)
    end
  end
end
