require 'delegate'

module View
  class EmailRecipientEvent < SimpleDelegator
    attr_reader :context, :event

    def initialize(event, context)
      @event = event
      @context = context
      super(@event)
    end

    def _links
      {self:      self_link,
       email_recipient: recipient_link}
    end

    def event_at
      event.public_send(:"#{event_type(event.class.name)}ed_at")
    end

    private

    def event_type(class_name)
      # 'EmailRecipientOpen'.underscore.split('_').last
      class_name.underscore.split('_').last
    end

    def self_link
      opts = {
        only_path:  true,
        format:     nil,
        controller: context.controller_name,
        action:     'show',
        id:         event.id
      }
      context.url_for(opts)
    end

    def recipient_link
      return nil unless event.id
      opts = recipients_controller_options.merge(email_id: event.email_message_id,
                                                 id: event.email_recipient_id,
                                                 action: 'show')
      context.url_for(opts)
    end

    def recipients_controller_options
      {controller: 'recipients', only_path: true, format: nil}
    end
  end
end
