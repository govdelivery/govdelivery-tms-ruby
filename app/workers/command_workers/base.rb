require 'app/workers/base'
require 'app/transformers/base'

module CommandWorkers
  module Base
    def self.included(base)
      base.send(:include, ::Workers::Base)
      base.send(:include, InstanceMethods)
      base.sidekiq_options queue: :webhook

      base.sidekiq_retries_exhausted do |msg|
        Sidekiq.logger.warn "Sidekiq job failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
      end

    end

    module InstanceMethods
      attr_accessor :http_service, :http_response, :exception
      attr_reader :command

      def perform(opts)
        options = CommandParameters.new(opts)
        @command = Command.includes(keyword: :account).find(options.command_id)
        yield(options) if block_given?
        @command.process_response(options, self.http_response)
      rescue Transformers::InvalidResponse => e
        Rails.logger.warn(e)
        Rails.logger.warn(e.message)
        nil
      end

    end
  end
end
