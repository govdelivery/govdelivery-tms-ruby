class MessagePresenter < SimpleDelegator
  attr_reader :context, :message

  def initialize(message, context)
    @message = message
    @context = context
    super(@message)
  end

  def _links
    if @message.new_record?
      {self: new_link} # create failed
    else
      {self: self_link}
        .merge(recipient_action_links)
        .merge(email_links)
        .merge(voice_links)
    end
  end

  def recipient_action_links
    {recipients: recipients_link,
     failed: failed_link,
     sent: sent_link}
  end

  def email_links
    message_type == 'email' ? {clicked: clicked_link, opened: opened_link}.merge(insert_email_template_link) : {}
  end

  def voice_links
    message_type == 'voice' ? {human: human_link, machine: machine_link, busy: busy_link, no_answer: no_answer_link, could_not_connect: could_not_connect_link} : {}
  end

  private

  def self_link
    context.send(:"#{message_type}_path", @message)
  end

  # polymorphic_path doesn't work here
  def message_type
    @message.class.name.underscore.split('_').first # sms,voice,email
  end

  def new_link
    context.send(:"#{message_type}_index_path") # could also be #new, but this can be POST'ed to.
  end

  def failed_link
    context.send(:"failed_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def sent_link
    context.send(:"sent_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def human_link
    context.send(:"human_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def machine_link
    context.send(:"machine_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def busy_link
    context.send(:"busy_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def no_answer_link
    context.send(:"no_answer_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def could_not_connect_link
    context.send(:"could_not_connect_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def clicked_link
    context.send("clicked_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def opened_link
    context.send("opened_#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end

  def insert_email_template_link
    @message.email_template.blank? ? {} : {email_template: context.templates_email_path(@message.email_template)}
  end

  def recipients_link
    # sms_recipients_path
    context.send(:"#{message_type}_recipients_path", :"#{message_type}_id" => @message.id)
  end
end
