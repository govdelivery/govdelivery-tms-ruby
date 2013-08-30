module Workers
  module CommandWorker
    def self.included(base)
      base.send(:include, Workers::Base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      attr_accessor :http_service, :http_response, :exception
      attr_reader :options

      def perform(opts)
        command.process_response(self.account, self.options, self.http_response)
      end

      def options=(opts)
        @options = CommandParameters.new(opts)
        logger.info("Invoking #{self.class.name} for #{self.options.to_hash.inspect}")
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