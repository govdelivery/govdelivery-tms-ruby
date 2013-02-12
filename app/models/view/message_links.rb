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
       :recipients => all_recipients_link}.tap do |hsh|
        if message_type == 'email'
          hsh[:clicked] = clicked_link
          hsh[:opened]  = opened_link
        end
      end
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

    def message_type
      context.controller_name.split('_').first
    end

    def clicked_link
      recip_link('clicked')
    end

    def opened_link
      recip_link('opened')
    end

    def all_recipients_link
      recip_link
    end

    def recip_link(action=nil)
      return nil unless message.id
      opts = recipients_controller_options
      opts.merge!(:action => action) unless action.nil?
      opts[:"#{message_type}_id"] = message.id
      context.url_for(opts)
    end

    def recipients_controller_options
      {:controller=>'recipients', :only_path => true, :format => nil}
    end
  end
end
