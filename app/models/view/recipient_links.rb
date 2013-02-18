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
      links = {self: self_link}.merge(message_link)
      if recipient.class.name.downcase.include?('email')
        links.merge(opens: context.url_for(action: 'index', controller: 'opens', only_path: true, format: nil, email_id: recipient.message_id, recipient_id: recipient.id))
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
      return nil unless recipient.id
      opts = {
        only_path: true,
        format: nil,
        controller: recipient.message.class.table_name,
        action: 'show',
        id: recipient.message_id
      }
      {:"#{recipient.message.class.name.underscore}" => context.url_for(opts)}
    end
  end
end
