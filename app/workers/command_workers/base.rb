require 'app/workers/base'
module CommandWorkers
  module Base
    def self.included(base)
      base.send(:include, ::Workers::Base)
      base.send(:include, InstanceMethods)
      base.sidekiq_options queue: :command

      base.sidekiq_retries_exhausted do |msg|
        logger.warn "Sidekiq job failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
      end

    end

    module InstanceMethods
      attr_accessor :http_service, :http_response, :exception
      attr_reader :options

      def perform(opts)
        command.process_response(self.account, self.options, self.http_response)
      rescue Transformers::InvalidResponse => e
        Rails.logger.warn(e)
        Rails.logger.warn(e.message)
        nil
      end

      def options=(opts)
        @options = CommandParameters.new(opts)
      end

      def account
        @account ||= Account.find(self.options.account_id)
      end

      def command
        @command ||= Command.find(self.options.command_id)
      end
    end
  end
end
