require 'delegate'

module View
  class MessageLinks < SimpleDelegator
    attr_reader :context, :message

    def initialize(message, context)
      @message = message
      @context = context
      super(@message)
    end

    def _links
      {:self       => self_link,
       :recipients => recipients_link}
    end

    private

    def self_link
      opts = {:only_path => true, :format => nil}
      if message.persisted?
        context.url_for(opts.merge(:controller=>context.controller_name, :action=>'show', :id=>message.id))
      else
        context.url_for(opts.merge(:controller=>context.controller_name))
      end
    end

    def recipients_link
      return nil unless message.id
      opts = {:controller=>'recipients', :only_path => true, :format => nil}
      message_type = context.controller_name.split('_').first
      opts["#{message_type}_id"] = message.id
      context.url_for(opts)
    end
  end
end
