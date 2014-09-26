require 'base'

module Messages
  class CheckMessageForCompletion
    include Workers::Base
    sidekiq_options queue:       :low,
                    retry:       false,
                    unique_args: ->(args) { [args['message_class'], args['message_id']] }

    def perform(args)
      klass = args['message_class'].constantize
      if (message = klass.without_message.find(args['message_id']))
        return if message.completed?
        logger.debug("Checking completion status for message #{message.class.name} #{message.id}")
        message.complete!
      end
    end
  end
end
