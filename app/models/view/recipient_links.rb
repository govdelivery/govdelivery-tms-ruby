require 'delegate'

module View
  class RecipientLinks < SimpleDelegator
    attr_reader :context, :recipient

    def initialize(recipient, context)
      @recipient = recipient
      @context = context
      super(@recipient)
    end

    def _links
      links = {:self => self_link, message_name => message_link}
      if recipient.class.name.downcase.include?('email')
        links.merge(:opens => opens_link)
      else
        links
      end
    end

    private

    def self_link
      opts = {
        only_path:  true,
        format:     nil,
        controller: 'recipients',
        action:     'show',
        id:         recipient.id
      }
      context.url_for(opts)
    end

    def message_link
      return {} unless recipient.id
      opts = {
        only_path: true,
        format: nil,
        controller: recipient.message.class.table_name,
        action: 'show',
        id: recipient.message_id
      }
      context.url_for(opts)
    end

    def message_name
      :"#{recipient.message.class.name.underscore}"
    end

    def opens_link
      context.url_for(action: 'index',
                      controller: 'opens',
                      only_path: true,
                      format: nil,
                      email_id: recipient.message_id,
                      recipient_id: recipient.id)
    end
  end
end
