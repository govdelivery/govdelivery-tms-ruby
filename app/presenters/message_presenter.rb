class MessagePresenter < SimpleDelegator
  attr_reader :context, :message

  def initialize(message, context)
    @message = message
    @context = context
    super(@message)
  end

  def _links
    if @message.new_record?
      {self: new_link,} #create failed
    else
      {self: self_link,}.
        merge(recipient_action_links).
        merge(email_links)
    end
  end

  def recipient_action_links
    { recipients:        recipients_link,
      failed: failed_link,
      sent:   sent_link,}
  end

  def email_links
    message_type == 'email' ? {clicked: clicked_link, opened: opened_link} : {}
  end

  private

  def self_link
    context.send(:"#{message_type}_path", id: @message.id)
  end

  #polymorphic_path doesn't work here
  def message_type
    @message.class.name.underscore.split('_').first #sms,voice,email
  end

  def new_link
    context.send(:"#{message_type}_index_path") #could also be #new, but this can be POST'ed to.
  end

  def failed_link
    context.send(:"failed_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def sent_link
    context.send(:"sent_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def clicked_link
    context.send(:"clicked_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def opened_link
    context.send(:"opened_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def recipients_link
    # sms_recipients_path
    context.send(:"#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end
end
